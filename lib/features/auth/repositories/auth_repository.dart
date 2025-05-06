// Dart imports:
import 'dart:io';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Interface for authentication-related operations
abstract class IAuthRepository {
  /// Gets the currently authenticated user
  /// Returns null if no user is authenticated
  Future<supabase.User?> getCurrentUser();

  /// Checks if an email is already registered
  /// Returns true if the email exists in the database
  Future<bool> isEmailRegistered(String email);

  /// Signs up a new user with email and password
  /// Throws [ValidationException] if email or password is invalid
  /// Throws [AuthException] if signup fails
  Future<supabase.User> signUp(String email, String password, String name);

  /// Signs in a user with email and password
  /// Throws [ValidationException] if email or password is invalid
  /// Throws [AuthException] if credentials are incorrect
  Future<supabase.User> signIn(String email, String password);

  /// Signs out the current user
  /// Throws [AuthException] if signout fails
  Future<void> signOut();

  /// Resets the password for the given email
  /// Throws [ValidationException] if email is invalid
  /// Throws [AuthException] if reset fails
  Future<void> resetPassword(String email);

  /// Updates the current user's profile
  /// Throws [AuthException] if user is not authenticated
  /// Throws [ValidationException] if data is invalid
  Future<void> updateProfile({String? name, String? photoUrl});

  /// Sign in with Google OAuth
  /// Throws [AuthException] if sign in fails
  Future<supabase.Session?> signInWithGoogle();

  /// Obtém a sessão atual se existir
  supabase.Session? getCurrentSession();
  
  /// Obtém o perfil do usuário atual
  /// Throws [AuthException] se o usuário não estiver autenticado
  Future<supabase.User?> getUserProfile();

  /// Renova a sessão do usuário atual
  /// Throws [AuthException] se houver erro na renovação
  Future<void> refreshSession();
}

/// Implementation of [IAuthRepository] using Supabase
class AuthRepository implements IAuthRepository {
  final supabase.SupabaseClient _supabaseClient;

  AuthRepository(this._supabaseClient);

  @override
  Future<supabase.User?> getCurrentUser() async {
    try {
      return _supabaseClient.auth.currentUser;
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to get current user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    try {
      debugPrint('🔍 AuthRepository: Verificando se o email existe: $email');
      
      // Primeiro verificar se a tabela 'profiles' existe
      try {
        // Tentativa inicial simples para verificar se a tabela existe
        final tableCheck = await _supabaseClient
            .from('profiles')
            .select('count')
            .limit(1);
        
        debugPrint('✅ Tabela profiles existe e está acessível');
      } catch (tableError) {
        debugPrint('⚠️ Erro ao acessar tabela profiles: $tableError');
        
        // Se houver erro ao acessar a tabela, assumir que o email não existe
        // mas logar para investigação
        if (tableError is supabase.PostgrestException) {
          debugPrint('⚠️ Código de erro Postgrest: ${tableError.code}');
          debugPrint('⚠️ Mensagem de erro: ${tableError.message}');
        }
        
        // Para efeitos de login existente, vamos assumir que o email não existe
        // se a tabela não estiver acessível
        return false;
      }
      
      // Se a tabela existe, verificar o email
      final result = await _supabaseClient
          .from('profiles')
          .select('email')
          .eq('email', email)
          .limit(1)
          .maybeSingle(); // Usa maybeSingle ao invés de single para evitar exceções
      
      // Se encontrou resultado, o email existe
      final exists = result != null;
      debugPrint('🔍 Email ${email} ${exists ? "existe" : "não existe"} na base de dados');
      return exists;
    } catch (e) {
      // Logar o erro para diagnóstico
      debugPrint('⚠️ Erro ao verificar email: $e');
      
      // Se for erro de "não encontrado", retorna false
      if (e is supabase.PostgrestException) {
        debugPrint('⚠️ Código de erro Postgrest: ${e.code}');
        
        if (e.code == 'PGRST116') {
          debugPrint('📝 Erro de não encontrado, o email não existe');
          return false;
        }
      }
      
      // Durante o login com credenciais existentes, vamos assumir que o email existe
      // para permitir a tentativa de login (better safe than sorry)
      // Durante o cadastro, assumir que não existe pode levar a duplicação de contas
      debugPrint('⚠️ Erro genérico, assumindo que o email existe por precaução');
      return true;
    }
  }

  @override
  Future<supabase.User> signUp(
      String email, String password, String name) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw ValidationException(message: 'Email, password and name are required');
    }

    try {
      // Verificar primeiro se o email já está registrado
      final emailExists = await isEmailRegistered(email);
      if (emailExists) {
        throw AppAuthException(
          message: 'Este email já está cadastrado. Por favor, faça login.',
          code: 'email_already_exists',
        );
      }

      // Prosseguir com o registro se o email não existir
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        throw AppAuthException(message: 'Sign up failed: no user returned');
      }

      // Verificar se precisamos fazer login automaticamente
      if (response.session == null) {
        try {
          final loginResponse = await _supabaseClient.auth.signInWithPassword(
            email: email,
            password: password,
          );
          
          if (loginResponse.user == null) {
            throw AppAuthException(message: 'Auto login after signup failed');
          }
          
          return loginResponse.user!;
        } catch (loginError) {
          // Se falhar o login automático, ainda retornamos o usuário criado
          print('Erro no login automático: $loginError');
          return response.user!;
        }
      }

      return response.user!;
    } on AppAuthException {
      // Re-lançar exceções AuthException já tratadas (como email já existente)
      rethrow;
    } on supabase.AuthException catch (e, stackTrace) {
      // Melhor tratamento de erros do Supabase
      String message = e.message;
      
      // Mensagens mais amigáveis para erros comuns
      if (message.toLowerCase().contains('already registered')) {
        message = 'Este email já está cadastrado. Por favor, faça login.';
      } else if (message.toLowerCase().contains('weak password')) {
        message = 'A senha é muito fraca. Use pelo menos 6 caracteres com letras e números.';
      } else if (message.toLowerCase().contains('invalid email')) {
        message = 'O email fornecido é inválido.';
      }
      
      throw AppAuthException(
        message: message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Falha ao registrar usuário: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<supabase.User> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw ValidationException(message: 'Email and password are required');
    }

    try {
      // Antes de tentar login, verificar se o email existe
      final emailExists = await isEmailRegistered(email);
      if (!emailExists) {
        throw AppAuthException(
          message: 'Conta não encontrada. Verifique seu email ou crie uma nova conta.',
          code: 'user_not_found',
        );
      }

      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppAuthException(message: 'Sign in failed: no user returned');
      }

      return response.user!;
    } on AppAuthException {
      // Re-lançar exceções AuthException já tratadas
      rethrow;
    } on supabase.AuthException catch (e, stackTrace) {
      String message = e.message;
      
      // Mensagens mais amigáveis para erros comuns
      if (message.toLowerCase().contains('invalid login')) {
        message = 'Email ou senha incorretos. Por favor, tente novamente.';
      } else if (message.toLowerCase().contains('not confirmed')) {
        message = 'Seu email ainda não foi confirmado. Por favor, verifique sua caixa de entrada.';
      } else if (message.toLowerCase().contains('too many requests')) {
        message = 'Muitas tentativas de login. Por favor, tente novamente mais tarde.';
      } else if (message.toLowerCase().contains('not found') || message.toLowerCase().contains('no user')) {
        message = 'Conta não encontrada. Verifique seu email ou crie uma nova conta.';
      }
      
      throw AppAuthException(
        message: message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Falha ao realizar login: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on supabase.AuthException catch (e, stackTrace) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to sign out user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      throw ValidationException(message: 'Email is required');
    }

    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } on supabase.AuthException catch (e, stackTrace) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to reset password',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      throw AppAuthException(message: 'User is not authenticated');
    }

    try {
      await _supabaseClient.auth.updateUser(
        supabase.UserAttributes(
          data: {
            if (name != null) 'name': name,
            if (photoUrl != null) 'avatar_url': photoUrl,
          },
        ),
      );
    } on supabase.AuthException catch (e, stackTrace) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to update profile',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  @override
  Future<supabase.Session?> signInWithGoogle() async {
    try {
      final platform = _getPlatform();
      if (platform == 'ios' || platform == 'android') {
        // Usar URL de redirecionamento fixa para garantir consistência
        const String redirectUrl = 'rayclub://login-callback/';
        
        debugPrint("🔍 AuthRepository: Iniciando login com Google. URL de redirecionamento: $redirectUrl");
        
        // Implementação com redirecionamento explícito
        final authResponse = await _supabaseClient.auth.signInWithOAuth(
          supabase.OAuthProvider.google,
          redirectTo: redirectUrl, // URL de redirecionamento explícita
        );
        
        // Log explícito para ajudar a diagnosticar problemas
        debugPrint("🔍 Login com Google iniciado: $authResponse");
        
        if (!authResponse) {
          throw AppAuthException(message: 'Falha ao iniciar login com Google');
        }
        
        // Aguardar pela sessão
        int attempts = 0;
        while (attempts < 30) { // Aumentamos o tempo de espera para 30 segundos
          await Future.delayed(const Duration(seconds: 1));
          final currentSession = _supabaseClient.auth.currentSession;
          if (currentSession != null) {
            debugPrint("✅ Sessão obtida com sucesso após login Google!");
            return currentSession;
          }
          attempts++;
          debugPrint("⏳ Aguardando sessão... Tentativa $attempts/30");
        }
        
        throw AppAuthException(message: 'Tempo esgotado aguardando pela sessão do Google');
      } else {
        // Para Web, mantém a mesma abordagem
        final response = await _supabaseClient.auth.signInWithOAuth(
          supabase.OAuthProvider.google,
          redirectTo: 'https://rayclub.vercel.app/auth/callback',
        );
        
        return _supabaseClient.auth.currentSession;
      }
    } on supabase.AuthException catch (e, stackTrace) {
      debugPrint("❌ Erro AuthException durante login com Google: ${e.message}");
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      debugPrint("❌ Erro genérico durante login com Google: $e");
      throw DatabaseException(
        message: 'Falha ao fazer login com Google: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  String _getPlatform() {
    if (identical(0, 0.0)) {
      return 'web';
    }
    
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    
    return 'unknown';
  }

  /// Obtém a sessão atual se existir
  supabase.Session? getCurrentSession() {
    return _supabaseClient.auth.currentSession;
  }
  
  /// Obtém o perfil do usuário atual
  @override
  Future<supabase.User?> getUserProfile() async {
    try {
      // Apenas retorna o usuário atual do Supabase
      return _supabaseClient.auth.currentUser;
    } catch (e, stackTrace) {
      throw AppAuthException(
        message: 'Falha ao obter perfil do usuário',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Renova a sessão do usuário atual
  @override
  Future<void> refreshSession() async {
    try {
      await _supabaseClient.auth.refreshSession();
    } catch (e, stackTrace) {
      throw AppAuthException(
        message: 'Erro ao renovar sessão',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
} 

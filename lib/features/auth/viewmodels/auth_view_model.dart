// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../models/auth_state.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

/// Constante que define o intervalo de verificação periódica em segundo plano (em minutos)
const int BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES = 30;

/// Provider global para o AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository: repository);
});

/// Provider para o repositório de autenticação
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepository(supabaseClient);
});

/// ViewModel responsável por gerenciar operações relacionadas à autenticação.
class AuthViewModel extends StateNotifier<AuthState> {
  final IAuthRepository _repository;
  String? _redirectPath;
  Timer? _backgroundAuthCheckTimer;

  AuthViewModel({
    required IAuthRepository repository,
    bool checkAuthOnInit = true,
  })  : _repository = repository,
        super(const AuthState.initial()) {
    if (checkAuthOnInit) {
      checkAuthStatus();
    }
    
    // Iniciar verificação periódica em segundo plano
    _startBackgroundAuthCheck();
  }

  /// Inicia a verificação periódica de autenticação em segundo plano
  void _startBackgroundAuthCheck() {
    // Cancele qualquer timer existente
    _backgroundAuthCheckTimer?.cancel();
    
    // Crie um novo timer para verificação periódica
    _backgroundAuthCheckTimer = Timer.periodic(
      Duration(minutes: BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES),
      (_) => _performBackgroundAuthCheck()
    );
    
    debugPrint('🔄 AuthViewModel: Iniciado verificador periódico de autenticação a cada $BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES minutos');
  }
  
  /// Realiza a verificação de autenticação em segundo plano
  /// Esta verificação é silenciosa e não altera o estado para loading
  Future<void> _performBackgroundAuthCheck() async {
    debugPrint('🔄 AuthViewModel: Realizando verificação periódica de autenticação em segundo plano');
    
    try {
      // Verificar se há um usuário autenticado no estado atual
      final isCurrentlyAuthenticated = state.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      
      // Se não estiver autenticado, não precisamos verificar
      if (!isCurrentlyAuthenticated) {
        debugPrint('🔄 AuthViewModel: Estado atual não é autenticado, pulando verificação em segundo plano');
        return;
      }
      
      // Verificar e renovar a sessão se necessário, sem alterar o estado para loading
      await verifyAndRenewSession(silent: true);
      
    } catch (e) {
      // Apenas log, sem alterar o estado
      debugPrint('⚠️ AuthViewModel: Erro em verificação de autenticação em segundo plano: $e');
    }
  }

  @override
  void dispose() {
    // Cancelar o timer quando o ViewModel for descartado
    _backgroundAuthCheckTimer?.cancel();
    super.dispose();
  }

  /// Obtém o caminho para redirecionamento (se existir)
  String? get redirectPath => _redirectPath;

  /// Define o caminho para redirecionamento após login
  void setRedirectPath(String path) {
    _redirectPath = path;
  }

  /// Limpa o caminho de redirecionamento
  void clearRedirectPath() {
    _redirectPath = null;
  }

  /// Extrai a mensagem de erro de uma exceção
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }

  /// Verifica o status atual de autenticação
  Future<void> checkAuthStatus() async {
    // Não mudar para loading se já estiver autenticado
    // Isso evita flickering de UI desnecessário
    final isCurrentlyAuthenticated = state.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    // Se não estiver autenticado, mostrar loading
    if (!isCurrentlyAuthenticated) {
      state = const AuthState.loading();
    }
    
    try {
      // Verificar e renovar a sessão se necessário
      final isSessionValid = await verifyAndRenewSession();
      
      // Se já tratamos a sessão e atualizamos o estado, não precisamos fazer mais nada
      if (isSessionValid) {
        return;
      }
      
      // Caso contrário, verificar se há um usuário autenticado
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(
          user: AppUser.fromSupabaseUser(user),
        );
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      // Log de erro, mas não alterar estado para erro
      // Isso evita que um erro de verificação de sessão bloqueie o app
      print("Erro ao verificar status de autenticação: ${e.toString()}");
      // Em caso de erro, considerar como não autenticado
      state = const AuthState.unauthenticated();
    }
  }

  /// Verifica se um email já está registrado
  Future<bool> isEmailRegistered(String email) async {
    try {
      return await _repository.isEmailRegistered(email);
    } catch (e) {
      // Em caso de erro, assumir que o email já existe por precaução
      print("Erro ao verificar email: ${e.toString()}");
      return true;
    }
  }

  /// Realiza login com email e senha
  Future<void> signIn(String email, String password) async {
    try {
      state = const AuthState.loading();
      
      // Verificar formato básico de email
      if (!_isValidEmail(email)) {
        state = const AuthState.error(message: "Por favor, insira um email válido");
        return;
      }
      
      // Verificar senha mínima
      if (password.length < 6) {
        state = const AuthState.error(message: "A senha deve ter pelo menos 6 caracteres");
        return;
      }
      
      // Verificar primeiro se o email existe no sistema
      final emailExists = await isEmailRegistered(email);
      if (!emailExists) {
        state = const AuthState.error(message: "Conta não encontrada. Verifique seu email ou crie uma nova conta.");
        return;
      }
      
      final user = await _repository.signIn(email, password);
      state = AuthState.authenticated(
        user: AppUser.fromSupabaseUser(user),
      );
    } catch (e) {
      final errorMsg = _getErrorMessage(e);
      // Tratamento de mensagens de erro específicas para melhorar feedback ao usuário
      if (errorMsg.toLowerCase().contains("invalid login credentials") || 
          errorMsg.toLowerCase().contains("email ou senha incorretos")) {
        state = const AuthState.error(message: "Email ou senha incorretos");
      } else if (errorMsg.toLowerCase().contains("network")) {
        state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
      } else if (errorMsg.toLowerCase().contains("conta não encontrada")) {
        state = const AuthState.error(message: "Conta não encontrada. Verifique seu email ou crie uma nova conta.");
      } else {
        state = AuthState.error(message: errorMsg);
      }
    }
  }

  /// Registra um novo usuário
  Future<void> signUp(String email, String password, String name) async {
    try {
      state = const AuthState.loading();
      
      // Validações de dados
      if (!_isValidEmail(email)) {
        state = const AuthState.error(message: "Por favor, insira um email válido");
        return;
      }
      
      if (password.length < 6) {
        state = const AuthState.error(message: "A senha deve ter pelo menos 6 caracteres");
        return;
      }
      
      if (name.isEmpty) {
        state = const AuthState.error(message: "Por favor, insira seu nome");
        return;
      }
      
      // Verificar se o email já está registrado antes de tentar o cadastro
      final emailExists = await isEmailRegistered(email);
      if (emailExists) {
        state = const AuthState.error(message: "Este email já está cadastrado. Por favor, faça login.");
        return;
      }
      
      final user = await _repository.signUp(email, password, name);
      state = AuthState.authenticated(
        user: AppUser.fromSupabaseUser(user),
      );
    } catch (e) {
      final errorMsg = _getErrorMessage(e);
      // Melhorar mensagens de erro para o usuário
      if (errorMsg.toLowerCase().contains("already registered") || 
          errorMsg.toLowerCase().contains("já está cadastrado")) {
        state = const AuthState.error(message: "Este email já está cadastrado. Por favor, faça login");
      } else if (errorMsg.toLowerCase().contains("network")) {
        state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
      } else {
        state = AuthState.error(message: errorMsg);
      }
    }
  }

  // Validador simples de formato de email
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  /// Realiza logout
  Future<void> signOut() async {
    try {
      state = const AuthState.loading();
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Solicita redefinição de senha para o email
  Future<void> resetPassword(String email) async {
    try {
      state = const AuthState.loading();
      await _repository.resetPassword(email);
      state = const AuthState.success(message: 'Email de redefinição de senha enviado');
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      state = const AuthState.loading();
      await _repository.updateProfile(
        name: name,
        photoUrl: photoUrl,
      );

      // Atualiza o estado do usuário atual se autenticado
      state.maybeWhen(
        authenticated: (user) {
          state = AuthState.authenticated(
            user: user.copyWith(
              name: name ?? user.name,
              photoUrl: photoUrl ?? user.photoUrl,
            ),
          );
        },
        orElse: () {},
      );
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Realiza login com Google
  Future<void> signInWithGoogle() async {
    try {
      state = const AuthState.loading();
      
      debugPrint("🔍 AuthViewModel: Iniciando login com Google");
      
      // Tenta obter a sessão usando o método de signin do repositório
      final session = await _repository.signInWithGoogle();
      
      debugPrint("🔍 AuthViewModel: Resultado da chamada signInWithGoogle: ${session != null ? 'Sessão obtida' : 'Sessão não obtida'}");
      
      // Aguarda um pouco para garantir que a sessão seja processada
      await Future.delayed(const Duration(seconds: 1));
      
      // Verifica se foi possível obter uma sessão válida
      if (session != null) {
        debugPrint("✅ AuthViewModel: Sessão obtida com sucesso: ${session.user?.email}");
        
        // Tenta obter o usuário atual
        final user = await _repository.getCurrentUser();
        
        if (user != null) {
          // Login bem-sucedido, usuário autenticado
          debugPrint("✅ AuthViewModel: Usuário encontrado: ${user.email}");
          state = AuthState.authenticated(
            user: AppUser.fromSupabaseUser(user),
          );
        } else {
          // Sessão existe mas não foi possível obter o usuário
          // Tentar novamente a verificação de usuário
          debugPrint("⚠️ AuthViewModel: Sessão existe mas usuário não encontrado, tentando novamente...");
          await Future.delayed(const Duration(seconds: 2));
          final retryUser = await _repository.getCurrentUser();
          
          if (retryUser != null) {
            debugPrint("✅ AuthViewModel: Usuário encontrado na segunda tentativa: ${retryUser.email}");
            state = AuthState.authenticated(
              user: AppUser.fromSupabaseUser(retryUser),
            );
          } else {
            debugPrint("❌ AuthViewModel: Usuário não encontrado mesmo após retry");
            state = const AuthState.error(
              message: 'Login com Google bem-sucedido, mas usuário não encontrado',
            );
          }
        }
      } else {
        // Não foi possível obter uma sessão (usuário cancelou ou outro erro)
        debugPrint("❌ AuthViewModel: Não foi possível obter sessão do login com Google");
        state = const AuthState.error(
          message: 'Falha no login com Google ou processo cancelado',
        );
      }
    } catch (e) {
      // Erros durante o processo de login
      debugPrint("❌ AuthViewModel: Erro durante login com Google: $e");
      final errorMsg = _getErrorMessage(e);
      if (errorMsg.toLowerCase().contains("network")) {
        state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
      } else {
        state = AuthState.error(message: errorMsg);
      }
    }
  }

  /// Verifica se existe uma sessão ativa e atualiza o estado
  Future<bool> checkAndUpdateSession() async {
    try {
      debugPrint("🔍 AuthViewModel: Verificando sessão ativa");
      final session = _repository.getCurrentSession();
      
      if (session != null) {
        debugPrint("✅ AuthViewModel: Sessão encontrada, ID: ${session.user.id}");
        debugPrint("✅ AuthViewModel: Email da sessão: ${session.user.email}");
        
        final user = await _repository.getUserProfile();
        if (user != null) {
          debugPrint("✅ AuthViewModel: Perfil de usuário obtido com sucesso: ${user.email}");
          // Criar um novo estado authenticated em vez de usar copyWith
          state = AuthState.authenticated(
            user: AppUser.fromSupabaseUser(user),
          );
          return true;
        } else {
          debugPrint("❌ AuthViewModel: Sessão existe mas não foi possível obter perfil do usuário");
        }
      } else {
        debugPrint("❌ AuthViewModel: Nenhuma sessão ativa encontrada");
      }
      return false;
    } catch (e) {
      debugPrint('❌ AuthViewModel: Erro ao verificar sessão: $e');
      return false;
    }
  }
  
  /// Verifica se a sessão atual é válida e renova se necessário
  /// Se silent for true, não atualiza o estado para loading
  Future<bool> verifyAndRenewSession({bool silent = false}) async {
    try {
      final session = _repository.getCurrentSession();
      if (session == null) {
        if (!silent) state = const AuthState.unauthenticated();
        return false;
      }
      
      // Verificar se o token está perto de expirar (menos de 1 hora)
      final expiresAt = session.expiresAt;
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      final oneHour = 60 * 60;
      
      if (expiresAt != null && (expiresAt - now) < oneHour) {
        debugPrint("🔄 AuthViewModel: Token próximo de expirar, renovando sessão");
        // Tentar renovar a sessão
        await _repository.refreshSession();
        
        // Verificar se a renovação foi bem-sucedida
        final updatedSession = _repository.getCurrentSession();
        if (updatedSession != null) {
          debugPrint("✅ AuthViewModel: Sessão renovada com sucesso, expira em: ${updatedSession.expiresAt}");
          
          // Atualizar estado com usuário atual
          final user = await _repository.getCurrentUser();
          if (user != null) {
            state = AuthState.authenticated(
              user: AppUser.fromSupabaseUser(user),
            );
          }
        } else {
          debugPrint("❌ AuthViewModel: Falha ao renovar sessão");
          if (!silent) state = const AuthState.unauthenticated();
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ AuthViewModel: Erro ao verificar/renovar sessão: ${e.toString()}');
      if (!silent) state = const AuthState.unauthenticated();
      return false;
    }
  }
} 

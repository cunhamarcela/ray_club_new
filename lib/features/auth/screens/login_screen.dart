// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

// Project imports:
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_textures.dart';
import '../../../core/theme/app_typography.dart';
import '../viewmodels/auth_view_model.dart';
import '../../../core/providers/service_providers.dart';
import '../../../services/deep_link_service.dart';
import '../../../auth_debug.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  StreamSubscription? _deepLinkSubscription;
  bool _isProcessingDeepLink = false;

  @override
  void initState() {
    super.initState();
    // Configurar listener para deep links
    _setupDeepLinkListener();
    
    // Executar diagnóstico em modo de desenvolvimento
    if (kDebugMode) {
      AuthDebugUtils.printAuthDebugInfo();
    }
  }

  @override
  void dispose() {
    debugPrint('LoginScreen: Encerrando resources');
    _emailController.dispose();
    _passwordController.dispose();
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  void _handleLogin() {
    debugPrint('👆 LoginScreen: Botão Login clicado');
    // Chamar diretamente a função de login real
    _performLogin();
  }
  
  // Função que realiza o login real
  void _performLogin() {
    try {
      setState(() {
        _emailError = null;
        _passwordError = null;
      });
      
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      bool isValid = true;
      
      if (email.isEmpty) {
        setState(() {
          _emailError = "Por favor, insira seu email";
        });
        isValid = false;
      } else if (!_isValidEmail(email)) {
        setState(() {
          _emailError = "Por favor, insira um email válido";
        });
        isValid = false;
      }
      
      if (password.isEmpty) {
        setState(() {
          _passwordError = "Por favor, insira sua senha";
        });
        isValid = false;
      } else if (password.length < 6) {
        setState(() {
          _passwordError = "A senha deve ter pelo menos 6 caracteres";
        });
        isValid = false;
      }
      
      if (isValid) {
        debugPrint('✅ LoginScreen: Dados válidos, chamando signIn');
        ref.read(authViewModelProvider.notifier).signIn(email, password);
      } else {
        debugPrint('❌ LoginScreen: Dados inválidos');
      }
    } catch (e) {
      debugPrint('❌ LoginScreen: Erro ao processar login: $e');
    }
  }
  
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  void _handleGoogleLogin() {
    debugPrint('👆 LoginScreen: Botão Google Login clicado');
    try {
      ref.read(authViewModelProvider.notifier).signInWithGoogle();
    } catch (e) {
      debugPrint('❌ LoginScreen: Erro ao iniciar login com Google: $e');
    }
  }

  // Método para testar o deep link manualmente
  void _testDeepLink() {
    debugPrint('🧪 Testando deep link manualmente');
    final deepLinkService = ref.read(deepLinkServiceProvider);
    
    // Simular recebimento do deep link
    const testUri = 'rayclub://login-callback/?auth_token=test';
    deepLinkService.processLink(testUri);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teste de deep link enviado. Verifique os logs.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToForgotPassword() {
    context.router.pushNamed(AppRoutes.forgotPassword);
  }

  void _navigateToSignUp() {
    context.router.pushNamed(AppRoutes.signup);
  }

  void _setupDeepLinkListener() {
    final deepLinkService = ref.read(deepLinkServiceProvider);
    
    debugPrint('LoginScreen: Configurando listener de deep links');
    
    _deepLinkSubscription = deepLinkService.deepLinkStream.listen((uri) {
      if (_isProcessingDeepLink) return; // Evitar processamento duplicado
      
      if (uri != null && deepLinkService.isAuthLink(uri)) {
        _isProcessingDeepLink = true;
        debugPrint('LoginScreen: Deep link de autenticação recebido: $uri');
        
        // Mostrar indicador de processamento
        _showProcessingDialog();
        
        // Verificar estado da sessão
        _checkSessionAfterDeepLink();
      }
    });
  }
  
  void _showProcessingDialog() {
    // Usar AlertDialog com um botão de cancelar como backup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Processando login', style: AppTypography.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Finalizando autenticação...',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isProcessingDeepLink = false;
            },
            child: const Text('Cancelar'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
      ),
    );
    
    // Segurança adicional: fechar o diálogo automaticamente após 20 segundos
    // se por algum motivo o fluxo normal não fechar
    Future.delayed(const Duration(seconds: 20), () {
      if (_isProcessingDeepLink && mounted) {
        try {
          Navigator.of(context).pop();
          debugPrint('🔍 LoginScreen: Diálogo fechado automaticamente por timeout');
          _isProcessingDeepLink = false;
        } catch (e) {
          // Ignorar erro se o diálogo já estiver fechado
        }
      }
    });
  }
  
  Future<void> _checkSessionAfterDeepLink() async {
    // Verificar se conseguimos obter sessão após deep link
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      if (!mounted) return; // Verificar se o widget ainda está montado
      
      // Verificar sessão diretamente via Supabase
      final viewModel = ref.read(authViewModelProvider.notifier);
      final hasSession = await viewModel.checkAndUpdateSession();
      
      debugPrint('LoginScreen: Verificação de sessão após deep link: $hasSession');
      
      // Evitar operações em contexto desmontado
      if (!mounted) return;
      
      if (hasSession) {
        // Fechar o diálogo de loading com verificação de contexto
        try {
          Navigator.of(context).pop(); // Fecha diálogo de loading
        } catch (e) {
          debugPrint('❌ LoginScreen: Erro ao fechar diálogo: $e');
          // Continuar mesmo com erro para garantir navegação
        }
        
        // Mostrar mensagem de sucesso e navegar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado com sucesso!')),
        );
        
        // Garantir navegação mesmo com erro no diálogo
        context.router.replace(const HomeRoute());
      } else {
        // Mostrar erro se não obtiver sessão
        if (mounted) {
          try {
            Navigator.of(context).pop(); // Fecha diálogo de loading
          } catch (e) {
            debugPrint('❌ LoginScreen: Erro ao fechar diálogo: $e');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível completar o login. Tente novamente.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('LoginScreen: Erro ao verificar sessão após deep link: $e');
      // Garantir que o app continue funcionando mesmo com erro
      if (mounted) {
        try {
          Navigator.of(context).pop(); // Tenta fechar o diálogo
        } catch (dialogError) {
          debugPrint('❌ LoginScreen: Erro ao fechar diálogo de erro: $dialogError');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na autenticação: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    
    // Adicionar log para diagnóstico
    debugPrint('🔍 LoginScreen - Estado atual: ${authState.runtimeType}');
    authState.maybeWhen(
      authenticated: (user) => debugPrint('✅ Usuário autenticado: ${user.id}'),
      error: (message) => debugPrint('❌ Erro de autenticação: $message'),
      orElse: () => debugPrint('ℹ️ Estado não tratado: ${authState.runtimeType}'),
    );

    // Email e senha para teste rápido
    if (kDebugMode) {
      _emailController.text = 'test@example.com';
      _passwordController.text = 'password123';
    }

    // Verificar se o estado é loading para mostrar carregamento nos botões
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    
    return Scaffold(
      body: Column(
        children: [
          // Full-width logo container - no padding, no margins
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image.asset(
              'assets/images/logos/app/logologin.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          
          // Scrollable content area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFFF7F2E9), // Tom creme claro
                    Color(0xFFF3E9E0), // Tom creme
                  ],
                ),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 30), // Spacing after logo
                      
                      // Título da tela
                      Text(
                        "Bem-vinda ao seu espaço",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'CenturyGothic', // Fonte secundária
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4D4D4D), // Cor charcoal da identidade
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Subtítulo
                      Text(
                        "Entre para continuar sua jornada de bem-estar",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'CenturyGothic',
                          fontSize: 16,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                      
                      SizedBox(height: 50),
                      
                      // Campo de Email
                      Material(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email",
                            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF8A8A8A)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            errorText: _emailError,
                          ),
                          enabled: !isLoading,
                          onChanged: (value) {
                            if (_emailError != null) {
                              setState(() {
                                _emailError = null;
                              });
                            }
                          },
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Campo de Senha
                      Material(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: "Senha",
                            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF8A8A8A)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Color(0xFF8A8A8A),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            errorText: _passwordError,
                          ),
                          enabled: !isLoading,
                          onChanged: (value) {
                            if (_passwordError != null) {
                              setState(() {
                                _passwordError = null;
                              });
                            }
                          },
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Link Esqueceu sua senha
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: !isLoading ? _navigateToForgotPassword : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Text(
                              "Esqueceu sua senha?",
                              style: TextStyle(
                                fontFamily: 'CenturyGothic',
                                fontSize: 14,
                                color: Color(0xFFE76339),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 40),
                      
                      // Botão de Login
                      SizedBox(
                        height: 54,
                        child: Material(
                          elevation: 2,
                          shadowColor: Color(0xFFE76339).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: !isLoading ? () {
                              debugPrint('🔄 Botão login pressionado');
                              _handleLogin();
                            } : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFE76339), // Cor coral/laranja da identidade
                                    Color(0xFFFF9566), // Tom mais claro
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: Center(
                                child: isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        "Entrar",
                                        style: TextStyle(
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Separador
                      Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFCCCCCC))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "ou",
                              style: TextStyle(
                                fontFamily: 'CenturyGothic',
                                color: Color(0xFF8A8A8A),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFCCCCCC))),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Botão Google
                      SizedBox(
                        height: 54,
                        child: Material(
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: !isLoading ? () {
                              debugPrint('👆 Botão Google pressionado');
                              _handleGoogleLogin();
                            } : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/google.png',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) => 
                                      Icon(Icons.public, size: 24, color: Colors.blue),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Continuar com Google",
                                    style: TextStyle(
                                      fontFamily: 'CenturyGothic',
                                      color: Color(0xFF4D4D4D),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 40),
                      
                      // Link para cadastro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Não tem uma conta?",
                            style: TextStyle(
                              fontFamily: 'CenturyGothic',
                              color: Color(0xFF8A8A8A),
                              fontSize: 14,
                            ),
                          ),
                          InkWell(
                            onTap: !isLoading ? _navigateToSignUp : null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Cadastre-se",
                                style: TextStyle(
                                  fontFamily: 'CenturyGothic',
                                  color: Color(0xFFE76339),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RotatingText extends StatelessWidget {
  final String text;
  final double radius;
  final TextStyle textStyle;
  
  const RotatingText({
    super.key,
    required this.text,
    required this.radius,
    required this.textStyle,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RotatingTextPainter(
        text: text,
        radius: radius,
        textStyle: textStyle,
      ),
      size: Size.square(radius * 2),
    );
  }
}

class _RotatingTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final TextStyle textStyle;
  
  _RotatingTextPainter({
    required this.text,
    required this.radius,
    required this.textStyle,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    
    final spacing = 0.22;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    for (int i = 0; i < text.length; i++) {
      final double angle = i * spacing;
      final char = text[i];
      
      canvas.save();
      canvas.rotate(angle);
      
      textPainter.text = TextSpan(
        text: char,
        style: textStyle,
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -radius));
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(_RotatingTextPainter oldDelegate) => 
    text != oldDelegate.text || 
    radius != oldDelegate.radius || 
    textStyle != oldDelegate.textStyle;
} 

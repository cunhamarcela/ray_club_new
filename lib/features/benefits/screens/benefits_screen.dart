// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../shared/bottom_navigation_bar.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../enums/benefit_type.dart';
import '../models/benefit.dart';
import '../viewmodels/benefit_view_model.dart';
import '../viewmodels/benefits_view_model.dart';
import '../widgets/benefit_card.dart';
import '../widgets/partners_grid.dart';
import '../widgets/qr_code_widget.dart';
import '../../../features/home/widgets/register_exercise_sheet.dart';
import 'package:flutter/services.dart';

/// The Benefits Screen that displays coupons and QR codes
class BenefitsScreen extends ConsumerStatefulWidget {
  const BenefitsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends ConsumerState<BenefitsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPartner;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedPartner = null;
        });
        
        // Update the activeTab based on the selected tab
        switch (_tabController.index) {
          case 0:
            ref.read(benefitsViewModelProvider.notifier).showAllBenefits();
            break;
          case 1:
            ref.read(benefitsViewModelProvider.notifier).filterByType(BenefitType.qrCode);
            break;
        }
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final benefitsState = ref.watch(benefitsViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Benefícios',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botão de administração
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: AppColors.textDark),
            tooltip: 'Administração',
            onPressed: () async {
              // Verificar se é admin antes de navegar
              final isAdmin = await ref.read(benefitViewModelProvider.notifier).isAdmin();
              
              if (isAdmin) {
                if (mounted) {
                  Navigator.pushNamed(context, '/admin/benefits');
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Você não tem permissão para acessar esta área'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Cupons'),
                Tab(text: 'QR Codes'),
              ],
            ),
          ),
        ),
      ),
      body: benefitsState.isLoading
          ? const AppLoading()
          : benefitsState.errorMessage != null
              ? AppErrorWidget(
                  message: benefitsState.errorMessage!,
                  onRetry: () => ref.read(benefitsViewModelProvider.notifier).loadBenefits(),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCouponsTab(benefitsState),
                    _buildQRCodesTab(benefitsState),
                  ],
                ),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildCouponsTab(BenefitsState state) {
    final coupons = state.filteredBenefits.where((b) => b.type == BenefitType.coupon).toList();
    
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.discount_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum cupom disponível no momento',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        return BenefitCard(
          benefit: coupons[index],
          onTap: () => _showCouponDetails(coupons[index]),
        );
      },
    );
  }

  Widget _buildQRCodesTab(BenefitsState state) {
    if (_selectedPartner != null) {
      final partnerBenefits = state.benefits
          .where((b) => 
              b.type == BenefitType.qrCode && 
              b.partner == _selectedPartner)
          .toList();
      
      if (partnerBenefits.isEmpty) {
        return _buildPartnersGrid(state);
      }
      
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPartner = null;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Voltar para parceiros',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: partnerBenefits.length,
              itemBuilder: (context, index) {
                return BenefitCard(
                  benefit: partnerBenefits[index],
                  onTap: () => _showQRCode(partnerBenefits[index]),
                );
              },
            ),
          ),
        ],
      );
    }
    
    return _buildPartnersGrid(state);
  }

  Widget _buildPartnersGrid(BenefitsState state) {
    // Filter partners that have QR code benefits
    final qrCodePartners = state.benefits
        .where((b) => b.type == BenefitType.qrCode)
        .map((b) => b.partner)
        .toSet()
        .toList();
    
    if (qrCodePartners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum parceiro com QR Code disponível',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Escolha um parceiro para gerar o QR Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          PartnersGrid(
            partners: qrCodePartners,
            onPartnerSelected: (partner) {
              setState(() {
                _selectedPartner = partner;
              });
            },
          ),
        ],
      ),
    );
  }

  void _showCouponDetails(Benefit benefit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    benefit.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (benefit.expiresAt != null) ...[
                      const Text(
                        'Validade',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Até ${benefit.expiresAt!.day}/${benefit.expiresAt!.month}/${benefit.expiresAt!.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (benefit.terms != null) ...[
                      const Text(
                        'Termos e Condições',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        benefit.terms!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Implementa a funcionalidade de copiar o cupom para a área de transferência
                  if (benefit.couponCode != null && benefit.couponCode!.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: benefit.couponCode!))
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cupom copiado para a área de transferência'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Copiar Cupom',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCode(Benefit benefit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    benefit.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: QRCodeWidget(
                  qrCode: benefit.qrCodeUrl!,
                  title: benefit.title,
                  description: benefit.description,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 

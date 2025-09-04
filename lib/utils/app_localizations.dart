import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const Map<String, Map<String, String>> _localizedValues = {
    'id': {
      // Settings Screen
      'settings': 'Pengaturan',
      'account': 'Akun',
      'email': 'Email',
      'language': 'Bahasa',
      'logout': 'Keluar',
      'confirm_logout': 'Konfirmasi Keluar',
      'logout_message': 'Apakah Anda yakin ingin keluar?',
      'cancel': 'Batal',
      'yes_logout': 'Ya, Keluar',
      'app': 'Info Aplikasi',
      'developer': 'Pengembang',
      'support': 'Beri dukungan❤️',
      'close': 'Tutup',
      'currency' : 'Mata uang',
      
      // Common
      'back': 'Kembali',
      'save': 'Simpan',
      'delete': 'Hapus',
      'edit': 'Edit',
      'add': 'Tambah',
      
      // Home Screen
      'home': 'Beranda',
      'bucket_summary': 'Ringkasan Keuangan',
      'Bucket_summary': 'Ringkasan Bucket',
      'total_income': 'Total Pendapatan',
      'total_expense': 'Total Pengeluaran',
      'balance': 'Saldo',
      'add_income': 'Tambah Pendapatan',
      'add_expense': 'Tambah Pengeluaran',
      'edit_expense': 'Edit Pengeluaran',
      'update_expense': 'Update Pengeluaran',
      'expense_updated_success': 'Pengeluaran berhasil diperbarui',
      'expense_added_success': 'Pengeluaran berhasil ditambahkan',
      'recent_transactions': 'Transaksi Terbaru',
      'no_transactions': 'Belum ada transaksi',
      'add_first_transaction': 'Tambahkan pendapatan atau pengeluaran pertama Anda untuk memulai',
      
      // Add Income/Expense
      'amount': 'Jumlah',
      'description': 'Deskripsi',
      'category': 'Kategori',
      'category_name': 'Nama Kategori',
      'add_custom_category': 'Tambah Kategori Kustom',
      'date': 'Tanggal',
      'amount_required': 'Jumlah tidak boleh kosong',
      'invalid_amount': 'Masukkan jumlah yang valid',
      'amount_must_be_positive': 'Jumlah harus lebih dari 0',
      'description_required': 'Deskripsi tidak boleh kosong',
      'error_occurred': 'Terjadi kesalahan: {error}',
      'income': 'Pendapatan',
      'expense': 'Pengeluaran',
      'all' : 'semua',
      'income_added_success': 'Pendapatan di tambahkan',
      
      // Categories
      'salary': 'Gaji',
      'project': 'Proyek',
      'competition': 'Kompetisi',
      'award': 'Penghargaan',
      'freelance': 'Freelance',
      'sale': 'Penjualan',
      'other': 'Lainnya',
      'business': 'Bisnis',
      'investment': 'Investasi',
      'other_income': 'Pendapatan Lainnya',
      'food': 'Makanan',
      'transportation': 'Transportasi',
      'entertainment': 'Hiburan',
      'fuel': 'Bahan Bakar',
      'groceries': 'Belanja',
      'health': 'Kesehatan',
      'rent': 'Sewa',
      'shopping': 'Belanja',
      'bills': 'Tagihan',
      'education': 'Pendidikan',
      'other_expense': 'Pengeluaran Lainnya',
      
      // Auth
      'login': 'Masuk',
      'signup': 'Daftar',
      'welcome_to': 'Selamat datang di ',
      'manage_income_expenses': 'Kelola pendapatan dan pengeluaran Anda dengan mudah',
      'continue_with_google': 'Lanjutkan dengan Google untuk menggunakan Aplikasi!',
      'email_required': 'Email diperlukan',
      'password_required': 'Password diperlukan',
      'invalid_email': 'Email tidak valid',
      'password_too_short': 'Password terlalu pendek',
      'login_failed': 'Gagal masuk',
      'signup_failed': 'Gagal mendaftar',
      'logout_success': 'Berhasil keluar',
      
      // Goals
      'goals': 'Target',
      'set_goal': 'Atur Target',
      'goal_amount': 'Jumlah Target',
      'goal_description': 'Deskripsi Target',
      'goal_achieved': 'Target Tercapai!',
      'goal_progress': 'Progress Target',
      'goal_passed': 'Target Terlewati',
      'days_left': 'hari tersisa',
      'goal_deleted': 'Target berhasil dihapus',
      
      // History
      'history': 'Riwayat',
      'all_transactions': 'Semua Transaksi',
      'filter_by_type': 'Filter berdasarkan tipe',
      'filter_by_date': 'Filter berdasarkan tanggal',
      'no_data': 'Tidak ada data',
      'no_income_found': 'Tidak ada pendapatan ditemukan',
      'no_expenses_found': 'Tidak ada pengeluaran ditemukan',
      'add_first_income': 'Tambahkan pendapatan pertama Anda untuk memulai',
      'add_first_expense': 'Tambahkan pengeluaran pertama Anda untuk memulai',
      'total_expenses': 'Total Pengeluaran',
      'this_month': 'Bulan Ini',
      'last_month': 'Bulan Lalu',
      'this_year': 'Tahun Ini',
      
      // Messages
      'success': 'Berhasil',
      'error': 'Error',
      'warning': 'Peringatan',
      'info': 'Informasi',
      'data_saved': 'Data berhasil disimpan',
      'data_deleted': 'Data berhasil dihapus',
      'confirm_delete': 'Konfirmasi Hapus',
      'delete_message': 'Apakah Anda yakin ingin menghapus item ini?',
      'yes_delete': 'Ya, Hapus',
      // Delete Category Dialog
      'delete_category': 'Hapus Kategori',
      'delete_category_confirm': 'Apakah Anda yakin ingin menghapus kategori ini?',
    },
    'en': {
      // Settings Screen
      'settings': 'Settings',
      'account': 'Account',
      'email': 'Email',
      'language': 'Language',
      'logout': 'Logout',
      'confirm_logout': 'Confirm Logout',
      'logout_message': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'yes_logout': 'Yes, Logout',
      'about': 'About App',
      'app_name': 'Income Tracker',
      'app_version': 'Version 1.0.0',
      'app_description': 'An app to track your income and expenses easily and efficiently.',
      'developer': 'Developer',
      'developer_name': 'ITmabruh',
      'contact': 'Contact',
      'email_contact': 'contact@itmabruh.com',
      'features': 'Features',
      'feature_income_tracking': '• Income and expense tracking',
      'feature_categories': '• Customizable transaction categories',
      'feature_goals': '• Financial goal setting',
      'feature_history': '• Complete transaction history',
      'feature_multilingual': '• Multi-language support',
      'feature_cloud_sync': '• Cloud sync with Firebase',
      'close': 'Close',
      'currency' : 'Currencies',

      // Common
      'back': 'Back',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      
      // Home Screen
      'home': 'Home',
      'bucket_summary': 'Financial Summary',
      'total_income': 'Total Income',
      'total_expense': 'Total Expense',
      'balance': 'Balance',
      'add_income': 'Add Income',
      'edit_income': 'Edit Income',
      'update_income': 'Update Income',
      'income_updated_success': 'Income updated successfully',
      'income_added_success': 'Income added successfully',
      'add_expense': 'Add Expense',
      'edit_expense': 'Edit Expense',
      'update_expense': 'Update Expense',
      'expense_updated_success': 'Expense updated successfully',
      'expense_added_success': 'Expense added successfully',
      'recent_transactions': 'Recent Transactions',
      'no_transactions': 'No transactions yet',
      'add_first_transaction': 'Add your first income or expense to get started',
      
      // Add Income/Expense
      'amount': 'Amount',
      'description': 'Description',
      'category': 'Category',
      'category_name': 'Category Name',
      'add_custom_category': 'Add Custom Category',
      'date': 'Date',
      'amount_required': 'Amount cannot be empty',
      'invalid_amount': 'Enter a valid amount',
      'amount_must_be_positive': 'Amount must be bigger than 0',
      'description_required': 'Description cannot be empty',
      'error_occurred': 'An error occurred: {error}',
      'income': 'Income',
      'expense': 'Expense',
      'all' : 'All',
      
      // Categories
      'salary': 'Salary',
      'project': 'Project',
      'competition': 'Competition',
      'award': 'Award',
      'freelance': 'Freelance',
      'sale': 'Sale',
      'other': 'Other',
      'business': 'Business',
      'investment': 'Investment',
      'other_income': 'Other Income',
      'food': 'Food',
      'transportation': 'Transportation',
      'entertainment': 'Entertainment',
      'fuel': 'Fuel',
      'groceries': 'Groceries',
      'health': 'Health',
      'rent': 'Rent',
      'shopping': 'Shopping',
      'bills': 'Bills',
      'education': 'Education',
      'other_expense': 'Other Expense',
      
      // Goals
      'goals': 'Goals',
      'set_goal': 'Set Goal',
      'goal_amount': 'Goal Amount',
      'goal_description': 'Goal Description',
      'goal_achieved': 'Goal Achieved!',
      'goal_progress': 'Goal Progress',
      'goal_passed': 'Goal Passed',
      'days_left': 'days left',
      'goal_deleted': 'Goal deleted successfully',
      
      // History
      'history': 'History',
      'all_transactions': 'All Transactions',
      'filter_by_type': 'Filter by type',
      'filter_by_date': 'Filter by date',
      'no_data': 'No data available',
      'no_income_found': 'No income found',
      'no_expenses_found': 'No expenses found',
      'add_first_income': 'Add your first income to get started',
      'add_first_expense': 'Add your first expense to get started',
      'total_expenses': 'Total Expenses',
      'this_month': 'This Month',
      'last_month': 'Last Month',
      'this_year': 'This Year',
      
      // Messages
      'success': 'Success',
      'error': 'Error',
      'warning': 'Warning',
      'info': 'Information',
      'data_saved': 'Data saved successfully',
      'data_deleted': 'Data deleted successfully',
      'confirm_delete': 'Confirm Delete',
      'delete_message': 'Are you sure you want to delete this item?',
      'yes_delete': 'Yes, Delete',
      // Delete Category Dialog
      'delete_category': 'Delete Category',
      'delete_category_confirm': 'Are you sure you want to delete this category?',
    },
  };
  
  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
  
  String getCategoryName(String categoryKey) {
    return get(categoryKey.toLowerCase());
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['id', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
} 
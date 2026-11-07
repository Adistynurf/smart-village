# Sehat Bersama – Smart Village Kabupaten Lebak

Aplikasi Flutter untuk mencari rumah sakit, puskesmas, dan klinik di Kabupaten Lebak.

## Fitur
- Halaman pembuka
- Beranda dan kategori fasilitas kesehatan
- Pencarian nama fasilitas
- Daftar dan detail fasilitas beserta jenis pelayanan
- Peta OpenStreetMap dengan marker fasilitas
- GPS perangkat dan perhitungan jarak
- Favorit
- Profil
- Membuka rute fasilitas melalui Google Maps

## Cara menjalankan di Windows
1. Ekstrak ZIP.
2. Buka PowerShell di folder hasil ekstrak.
3. Jalankan `.\setup_project.ps1`.
4. Setelah selesai, buka `C:\FlutterProjects\sehat_bersama` melalui Android Studio.
5. Pilih emulator/perangkat Android lalu tekan Run.

Script akan membuat kerangka Android Flutter baru menggunakan Flutter SDK yang sudah terpasang, lalu menyalin source aplikasi ke dalamnya. Ini menghindari masalah Gradle wrapper yang rusak dari project lama.

## Catatan data
Nama fasilitas dan titik koordinat pada source merupakan data awal/contoh untuk demo. Verifikasi kembali alamat, nomor telepon, jam layanan, daftar layanan, dan koordinat dengan sumber resmi fasilitas kesehatan Kabupaten Lebak sebelum presentasi/publikasi. Peta memerlukan koneksi internet.

## Geofencing
Versi ini menyediakan GPS dan jarak fasilitas. Notifikasi otomatis saat masuk/keluar radius geofence di background belum dibuat.

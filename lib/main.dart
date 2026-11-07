import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

const blue = Color(0xFF1769D2);
const navy = Color(0xFF17365D);
const bg = Color(0xFFF5F8FC);

void main() => runApp(const SehatBersamaApp());

class SehatBersamaApp extends StatelessWidget {
  const SehatBersamaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Sehat Bersama',
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: blue),
      scaffoldBackgroundColor: bg, fontFamily: 'Roboto'),
    home: const WelcomePage(),
  );
}

class HealthPlace {
  final String name, category, address, hours, phone, description;
  final LatLng point;
  final List<String> services;
  const HealthPlace({required this.name, required this.category, required this.address,
    required this.hours, required this.phone, required this.description,
    required this.point, required this.services});
}

const places = <HealthPlace>[
  HealthPlace(name:'RSUD dr. Adjidarmo', category:'Rumah Sakit',
    address:'Jl. Hardiwinangun No. 1, Rangkasbitung, Kabupaten Lebak',
    hours:'24 Jam', phone:'(0252) 201111',
    description:'Rumah sakit umum daerah yang melayani masyarakat Kabupaten Lebak.',
    point:LatLng(-6.3547,106.2498),
    services:['IGD 24 Jam','Rawat Jalan','Rawat Inap','Laboratorium','Radiologi']),
  HealthPlace(name:'RS Misi Lebak', category:'Rumah Sakit',
    address:'Rangkasbitung, Kabupaten Lebak, Banten',
    hours:'Sesuai jadwal layanan', phone:'Hubungi fasilitas',
    description:'Fasilitas pelayanan kesehatan rumah sakit di wilayah Rangkasbitung.',
    point:LatLng(-6.3610,106.2470),
    services:['Rawat Jalan','Rawat Inap','Laboratorium']),
  HealthPlace(name:'RS Kartini Lebak', category:'Rumah Sakit',
    address:'Rangkasbitung, Kabupaten Lebak, Banten',
    hours:'Sesuai jadwal layanan', phone:'Hubungi fasilitas',
    description:'Fasilitas rumah sakit untuk kebutuhan pelayanan kesehatan masyarakat.',
    point:LatLng(-6.3488,106.2562),
    services:['Rawat Jalan','Rawat Inap','Farmasi']),
  HealthPlace(name:'Puskesmas Rangkasbitung', category:'Puskesmas',
    address:'Kecamatan Rangkasbitung, Kabupaten Lebak',
    hours:'Senin–Sabtu, jam kerja', phone:'Hubungi puskesmas',
    description:'Pusat pelayanan kesehatan tingkat pertama di Kecamatan Rangkasbitung.',
    point:LatLng(-6.3590,106.2510),
    services:['Pemeriksaan Umum','KIA/KB','Imunisasi','Kesehatan Gigi']),
  HealthPlace(name:'Puskesmas Kalanganyar', category:'Puskesmas',
    address:'Kecamatan Kalanganyar, Kabupaten Lebak',
    hours:'Senin–Sabtu, jam kerja', phone:'Hubungi puskesmas',
    description:'Puskesmas yang melayani masyarakat di wilayah Kalanganyar.',
    point:LatLng(-6.3720,106.2650),
    services:['Pemeriksaan Umum','Imunisasi','KIA/KB']),
  HealthPlace(name:'Klinik Medika', category:'Klinik',
    address:'Rangkasbitung, Kabupaten Lebak, Banten',
    hours:'Periksa jadwal fasilitas', phone:'Hubungi klinik',
    description:'Klinik layanan kesehatan umum di wilayah Rangkasbitung.',
    point:LatLng(-6.3500,106.2420),
    services:['Konsultasi Dokter','Pemeriksaan Umum','Farmasi']),
];

class LocationService extends ChangeNotifier {
  Position? position;
  String? error;
  StreamSubscription<Position>? _sub;
  Future<void> locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        error = 'Aktifkan GPS/lokasi pada perangkat.'; notifyListeners(); return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        error = 'Izin lokasi belum diberikan. Aktifkan melalui pengaturan aplikasi.';
        notifyListeners(); return;
      }
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      error = null; notifyListeners();
      await _sub?.cancel();
      _sub = Geolocator.getPositionStream(locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 20))
        .listen((p) { position = p; notifyListeners(); });
    } catch (e) {
      error = 'Lokasi belum bisa diperoleh. Coba aktifkan GPS.'; notifyListeners();
    }
  }
  double? distance(HealthPlace p) => position == null ? null :
    Geolocator.distanceBetween(position!.latitude, position!.longitude,
      p.point.latitude, p.point.longitude) / 1000;
  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}

final locationService = LocationService();

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(width: double.infinity, decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors:[Color(0xFFEAF4FF), Colors.white])),
      child: SafeArea(child: Padding(padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
          const Spacer(),
          Container(width:140,height:140,decoration: BoxDecoration(color:Colors.white,
            borderRadius:BorderRadius.circular(36), boxShadow:[BoxShadow(
              color:blue.withOpacity(.12),blurRadius:24,offset:const Offset(0,10))]),
            child: const Icon(Icons.health_and_safety_rounded,size:86,color:blue)),
          const SizedBox(height:28),
          const Text('Sehat Bersama',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:navy)),
          const Text('Smart Village Kabupaten Lebak',style:TextStyle(fontSize:16,color:blue,fontWeight:FontWeight.w600)),
          const SizedBox(height:14),
          const Text('Temukan rumah sakit, puskesmas, dan klinik serta informasi layanan kesehatan di sekitar Anda.',
            textAlign:TextAlign.center,style:TextStyle(color:Colors.black54,height:1.5)),
          const Spacer(),
          SizedBox(width:double.infinity,child:FilledButton(
            style:FilledButton.styleFrom(backgroundColor:blue,padding:const EdgeInsets.symmetric(vertical:16)),
            onPressed:()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const MainPage())),
            child:const Text('Mulai',style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)))),
          const SizedBox(height:12),
          const Text('Informasi fasilitas untuk wilayah Kabupaten Lebak, Banten',
            textAlign:TextAlign.center,style:TextStyle(fontSize:11,color:Colors.black45)),
        ]))),
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override State<MainPage> createState()=>_MainPageState();
}
class _MainPageState extends State<MainPage> {
  int tab=0;
  final favorites=<String>{};
  final pages=<String>['Beranda','Peta','Favorit','Profil'];
  @override void initState(){super.initState(); locationService.addListener(_refresh);}
  void _refresh(){if(mounted)setState((){});}
  @override void dispose(){locationService.removeListener(_refresh);super.dispose();}
  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index:tab,children:[
      HomeTab(favorites:favorites,onFavorite:_toggle,onOpen:_detail),
      MapTab(onOpen:_detail),
      FavoritesTab(favorites:favorites,onFavorite:_toggle,onOpen:_detail),
      const ProfileTab(),
    ])),
    bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),
      destinations:const[
        NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Beranda'),
        NavigationDestination(icon:Icon(Icons.map_outlined),selectedIcon:Icon(Icons.map),label:'Peta'),
        NavigationDestination(icon:Icon(Icons.favorite_border),selectedIcon:Icon(Icons.favorite),label:'Favorit'),
        NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'Profil'),
      ]),
  );
  void _toggle(HealthPlace p){setState(()=>favorites.contains(p.name)?favorites.remove(p.name):favorites.add(p.name));}
  void _detail(HealthPlace p)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>
    DetailPage(place:p,isFavorite:favorites.contains(p.name),onFavorite:()=>_toggle(p))));
}

class HomeTab extends StatefulWidget {
  final Set<String> favorites; final ValueChanged<HealthPlace> onFavorite; final ValueChanged<HealthPlace> onOpen;
  const HomeTab({super.key,required this.favorites,required this.onFavorite,required this.onOpen});
  @override State<HomeTab> createState()=>_HomeTabState();
}
class _HomeTabState extends State<HomeTab>{
  String category='Semua'; String query='';
  @override Widget build(BuildContext context){
    final filtered=places.where((p)=>(category=='Semua'||p.category==category)&&
      p.name.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(padding:const EdgeInsets.fromLTRB(18,14,18,24),children:[
      Row(children:[const Icon(Icons.location_on,color:blue),const SizedBox(width:5),
        const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Smart Village',style:TextStyle(fontWeight:FontWeight.bold,fontSize:20,color:navy)),
          Text('Kabupaten Lebak, Banten',style:TextStyle(color:Colors.black54,fontSize:12))])),
        IconButton(onPressed:locationService.locate,icon:const Icon(Icons.my_location,color:blue))]),
      const SizedBox(height:12),
      Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(22),gradient:const LinearGradient(colors:[blue,Color(0xFF4B9BEA)])),
        child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Sehat dimulai dari\ninformasi yang tepat',style:TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.bold)),
          SizedBox(height:8),Text('Cari fasilitas kesehatan di sekitar Kabupaten Lebak.',style:TextStyle(color:Colors.white70))])),
      const SizedBox(height:20),
      const Text('Kategori Layanan',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold,color:navy)),
      const SizedBox(height:12),
      Row(children:[
        _categoryIcon('Rumah Sakit',Icons.local_hospital,Color(0xFFFFE8EC)),
        _categoryIcon('Puskesmas',Icons.medical_services,Color(0xFFE6F7EC)),
        _categoryIcon('Klinik',Icons.health_and_safety,Color(0xFFE6F1FF)),
        _categoryIcon('Semua',Icons.apps,Color(0xFFFFF2DD)),
      ]),
      const SizedBox(height:20),
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        const Text('Fasilitas Kesehatan',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold,color:navy)),
        Text('${filtered.length} lokasi',style:const TextStyle(color:Colors.black45,fontSize:12))]),
      const SizedBox(height:10),
      TextField(onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(
        hintText:'Cari rumah sakit, puskesmas, klinik...',prefixIcon:const Icon(Icons.search),
        filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none))),
      const SizedBox(height:10),
      Wrap(spacing:8,children:['Semua','Rumah Sakit','Puskesmas','Klinik'].map((c)=>
        ChoiceChip(label:Text(c),selected:category==c,onSelected:(_)=>setState(()=>category=c))).toList()),
      const SizedBox(height:8),
      ...filtered.map((p)=>PlaceCard(place:p,favorite:widget.favorites.contains(p.name),
        onFavorite:()=>widget.onFavorite(p),onTap:()=>widget.onOpen(p))),
      if(locationService.error!=null) Padding(padding:const EdgeInsets.only(top:8),
        child:Text(locationService.error!,style:const TextStyle(color:Colors.red,fontSize:12))),
    ]);
  }
  Widget _categoryIcon(String c,IconData icon,Color color)=>Expanded(child:InkWell(
    onTap:()=>setState(()=>category=c),child:Column(children:[
      Container(width:55,height:55,decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(16)),
        child:Icon(icon,color:blue,size:27)),const SizedBox(height:7),
      Text(c=='Rumah Sakit'?'RS':c,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w600))])));
}

class PlaceCard extends StatelessWidget{
  final HealthPlace place; final bool favorite; final VoidCallback onFavorite,onTap;
  const PlaceCard({super.key,required this.place,required this.favorite,required this.onFavorite,required this.onTap});
  @override Widget build(BuildContext context)=>Card(color:Colors.white,elevation:0,margin:const EdgeInsets.only(bottom:10),
    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16),side:BorderSide(color:Colors.grey.shade100)),
    child:InkWell(borderRadius:BorderRadius.circular(16),onTap:onTap,child:Padding(padding:const EdgeInsets.all(12),
      child:Row(children:[
        Container(width:76,height:76,decoration:BoxDecoration(color:const Color(0xFFE8F2FF),borderRadius:BorderRadius.circular(12)),
          child:Icon(place.category=='Rumah Sakit'?Icons.local_hospital:place.category=='Puskesmas'?Icons.medical_services:Icons.health_and_safety,
            color:blue,size:36)),
        const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(place.name,style:const TextStyle(fontWeight:FontWeight.bold,color:navy)),
          const SizedBox(height:4),Text(place.category,style:const TextStyle(color:blue,fontSize:11)),
          const SizedBox(height:5),Text(place.address,maxLines:2,overflow:TextOverflow.ellipsis,
            style:const TextStyle(fontSize:11,color:Colors.black54)),
          const SizedBox(height:5),Text(locationService.distance(place)==null?'Jarak belum tersedia':'${locationService.distance(place)!.toStringAsFixed(1)} km dari Anda',
            style:const TextStyle(fontSize:11,color:Colors.green,fontWeight:FontWeight.w600)),
        ])),IconButton(onPressed:onFavorite,icon:Icon(favorite?Icons.favorite:Icons.favorite_border,
          color:favorite?Colors.red:Colors.grey)),
      ]))));
}

class MapTab extends StatelessWidget{
  final ValueChanged<HealthPlace> onOpen;
  const MapTab({super.key,required this.onOpen});
  @override Widget build(BuildContext context)=>Column(children:[
    const Padding(padding:EdgeInsets.fromLTRB(18,18,18,10),child:Row(children:[
      Text('Peta Lokasi',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold,color:navy))])),
    Expanded(child:FlutterMap(options:const MapOptions(initialCenter:LatLng(-6.3547,106.2498),initialZoom:12),
      children:[
        TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName:'com.example.sehat_bersama_lebak'),
        MarkerLayer(markers:[
          ...places.map((p)=>Marker(point:p.point,width:42,height:48,child:GestureDetector(
            onTap:()=>onOpen(p),child:const Icon(Icons.location_on,color:blue,size:42)))),
          if(locationService.position!=null) Marker(point:LatLng(locationService.position!.latitude,
            locationService.position!.longitude),width:38,height:38,
            child:const Icon(Icons.my_location,color:Colors.green,size:30)),
        ]),
      ])),
    Padding(padding:const EdgeInsets.all(12),child:Row(children:[
      Expanded(child:OutlinedButton.icon(onPressed:locationService.locate,
        icon:const Icon(Icons.my_location),label:const Text('Lokasi Saya'))),
      const SizedBox(width:10),Expanded(child:FilledButton.icon(onPressed:()=>showModalBottomSheet(
        context:context,builder:(_)=>ListView(children:places.map((p)=>ListTile(
          leading:const Icon(Icons.location_on,color:blue),title:Text(p.name),
          onTap:(){Navigator.pop(context);onOpen(p);})).toList())),
        icon:const Icon(Icons.list),label:const Text('Daftar Lokasi'))),
    ]))
  ]);
}

class FavoritesTab extends StatelessWidget{
  final Set<String> favorites; final ValueChanged<HealthPlace> onFavorite,onOpen;
  const FavoritesTab({super.key,required this.favorites,required this.onFavorite,required this.onOpen});
  @override Widget build(BuildContext context){
    final list=places.where((p)=>favorites.contains(p.name)).toList();
    return ListView(padding:const EdgeInsets.all(18),children:[
      const Text('Favorit',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),
      const SizedBox(height:12),
      if(list.isEmpty) const Padding(padding:EdgeInsets.all(30),child:Column(children:[
        Icon(Icons.favorite_border,size:55,color:Colors.black26),SizedBox(height:10),
        Text('Belum ada lokasi favorit',style:TextStyle(color:Colors.black54))])),
      ...list.map((p)=>PlaceCard(place:p,favorite:true,onFavorite:()=>onFavorite(p),onTap:()=>onOpen(p))),
    ]);
  }
}

class DetailPage extends StatelessWidget{
  final HealthPlace place; final bool isFavorite; final VoidCallback onFavorite;
  const DetailPage({super.key,required this.place,required this.isFavorite,required this.onFavorite});
  Future<void> _openMap() async {
    final uri=Uri.parse('https://www.google.com/maps/search/?api=1&query=${place.point.latitude},${place.point.longitude}');
    await launchUrl(uri,mode:LaunchMode.externalApplication);
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Detail Lokasi'),actions:[
      IconButton(onPressed:onFavorite,icon:Icon(isFavorite?Icons.favorite:Icons.favorite_border,color:isFavorite?Colors.red:null))]),
    body:ListView(padding:const EdgeInsets.all(18),children:[
      Container(height:170,decoration:BoxDecoration(color:const Color(0xFFE5F1FF),borderRadius:BorderRadius.circular(20)),
        child:const Icon(Icons.local_hospital,color:blue,size:90)),
      const SizedBox(height:16),Text(place.name,style:const TextStyle(fontSize:23,fontWeight:FontWeight.bold,color:navy)),
      Text(place.category,style:const TextStyle(color:blue,fontWeight:FontWeight.w600)),
      const SizedBox(height:14),_info(Icons.location_on,place.address),
      _info(Icons.access_time,place.hours),_info(Icons.phone,place.phone),
      const SizedBox(height:18),const Text('Jenis Pelayanan',style:TextStyle(fontSize:17,fontWeight:FontWeight.bold,color:navy)),
      const SizedBox(height:8),Wrap(spacing:8,runSpacing:8,children:place.services.map((s)=>
        Chip(avatar:const Icon(Icons.check_circle,color:blue,size:17),label:Text(s),backgroundColor:Colors.white)).toList()),
      const SizedBox(height:20),FilledButton.icon(onPressed:_openMap,icon:const Icon(Icons.map),label:const Text('Lihat Rute di Google Maps')),
      const SizedBox(height:8),const Text('Catatan: alamat, nomor telepon, jam layanan, dan titik koordinat perlu diverifikasi sebelum aplikasi digunakan secara resmi.',
        style:TextStyle(fontSize:11,color:Colors.black45)),
    ]));
  Widget _info(IconData i,String t)=>Padding(padding:const EdgeInsets.only(bottom:12),
    child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Icon(i,color:blue,size:20),const SizedBox(width:10),Expanded(child:Text(t))]));
}

class ProfileTab extends StatelessWidget{
  const ProfileTab({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[
    const Text('Profil',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),
    const SizedBox(height:25),const CircleAvatar(radius:42,backgroundColor:Color(0xFFE2F0FF),
      child:Icon(Icons.person,color:blue,size:48)),
    const SizedBox(height:12),const Center(child:Text('Pengguna Smart Village',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17))),
    const Center(child:Text('Kabupaten Lebak, Banten',style:TextStyle(color:Colors.black54))),
    const SizedBox(height:24),
    _item(Icons.location_on,'Lokasi Saya','Gunakan GPS untuk mengetahui jarak fasilitas',locationService.locate),
    _item(Icons.notifications_active,'Notifikasi','Pengaturan notifikasi aplikasi',()=>_message(context,'Notifikasi demo belum diaktifkan.')),
    _item(Icons.info_outline,'Tentang Aplikasi','Sehat Bersama – Smart Village',()=>showAboutDialog(context:context,
      applicationName:'Sehat Bersama',applicationVersion:'1.0.0',
      children:[const Text('Aplikasi pencarian fasilitas kesehatan Kabupaten Lebak berbasis Location Based Service (LBS).') ])),
    const SizedBox(height:20),const Text('Versi 1.0.0',textAlign:TextAlign.center,style:TextStyle(color:Colors.black38,fontSize:12)),
  ]);
  Widget _item(IconData icon,String title,String sub,VoidCallback action)=>ListTile(
    contentPadding:EdgeInsets.zero,leading:CircleAvatar(backgroundColor:const Color(0xFFE8F2FF),
      child:Icon(icon,color:blue)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w600)),
    subtitle:Text(sub,style:const TextStyle(fontSize:11)),trailing:const Icon(Icons.chevron_right),onTap:action);
  void _message(BuildContext c,String s)=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text(s)));
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skripsi_ba_parkir/app/controllers/page_index_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:skripsi_ba_parkir/app/routes/app_pages.dart';

import '../controllers/parking_controller.dart';

class ParkingView extends GetView<ParkingController> {
  ParkingView({Key? key}) : super(key: key);

  final PageIndexController pageC = Get.find<PageIndexController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1578662996442-48f60103fc96?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: // Bagian container dengan gambar dan teks
                Row(
              children: [
                // Bagian kiri (70% lebar)
                Expanded(
                  flex: 6, // Mengatur flex menjadi 7 untuk bagian kiri
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ba Parkir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Temukan dan kelola parkir dengan mudah di berbagai lokasi.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bagian kanan (30% lebar)
                Expanded(
                  flex: 4, // Mengatur flex menjadi 3 untuk bagian kanan
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 160,
                        height: 160,
                        child: Lottie.asset(
                          'assets/lotties/banner.json', // Sesuaikan dengan path file JSON Anda
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(left: 8.0, right: 8.0, bottom: 15.0, top: 15.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.crop_free),
                  onPressed: () {
                    // Handle scan icon click
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Cari Lokasi',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.favorite_border_outlined),
                  onPressed: () {
                    // Handle favorite icon click
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CategoryItem(
                        icon: Icons.shopping_bag_outlined, name: 'Belanja'),
                    CategoryItem(
                        icon: Icons.local_hospital_outlined,
                        name: 'Rumah Sakit'),
                    CategoryItem(
                        icon: Icons.restaurant_menu_outlined, name: 'Restoran'),
                    CategoryItem(
                        icon: Icons.local_play_outlined, name: 'Hiburan'),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CategoryItem(
                        icon: Icons.fitness_center_rounded, name: 'Gym'),
                    CategoryItem(icon: Icons.local_cafe_outlined, name: 'Kafe'),
                    CategoryItem(
                        icon: Icons.school_outlined, name: 'Pendidikan'),
                    CategoryItem(
                        icon: Icons.more_horiz_outlined, name: 'Lainnya'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: controller.streamMitra(),
              builder: (context, snapUser) {
                if (snapUser.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                Map<String, dynamic>? mitra = snapUser.data?.data();

                return FutureBuilder<int>(
                  future: controller.countSlots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    int slotCount = snapshot.data ?? 0;

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Add your navigation logic here
                            // For example, you can use Get.to to navigate to a new page
                            Get.toNamed(Routes.PARKING_SLOT);
                          },
                          child: LocationCard(
                            height: 200,
                            imagePath: mitra?["profile"],
                            locationName: mitra?["name"],
                            address: mitra?["address"],
                            capacity: slotCount,
                            rating: mitra?["rating"],
                          ),
                        ),

                        LocationCard(
                          height: 200,
                          imagePath:
                              'https://www.uii.ac.id/wp-content/uploads/2020/03/desain-rumah-sakit-uii-683x321.jpg',
                          locationName: 'Lokasi A',
                          address: 'Jl. Sis Aljufri No.36',
                          capacity: 40,
                          rating: 4.5,
                        ),
                        LocationCard(
                          height: 200,
                          imagePath:
                              'https://nusantarapedia.net/wp-content/uploads/IMG_10042022_172603_700_x_397_piksel.jpg',
                          locationName: 'Lokasi B',
                          address: 'Jl. Laut No.99',
                          capacity: 50,
                          rating: 4.0,
                        ),
                        // Add more LocationCard widgets as needed
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Rekomendasi Parkir',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    RecommendationCard(
                      width: 150,
                      imagePath:
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/New_york_times_square-terabass.jpg/1200px-New_york_times_square-terabass.jpg',
                      recommendationName: 'Tolis Grand Mall',
                      address: 'Jl. Veteran No.36',
                      capacity: 90,
                      rating: 4.5,
                    ),
                    RecommendationCard(
                      width: 150,
                      imagePath:
                          'https://cdnaz.cekaja.com/media/2023/01/10-Tempat-Hiburan-Malam-Paling-Seru-di-Bali_The-Lawn-Canggu.png',
                      recommendationName: 'Lokasi J',
                      address: 'Jl. Sam Ratulangi No.4',
                      capacity: 50,
                      rating: 4.5,
                    ),
                    RecommendationCard(
                      width: 150,
                      imagePath:
                          'https://i1.wp.com/www.watersportbali.co.id/wp-content/uploads/2019/02/17.-Ada-Apa-Saja-di-Kuta-Surganya-Wisata-Bali.jpg?fit=1024%2C576&ssl=1',
                      recommendationName: 'Lokasi K',
                      address: 'Jl. Emmy Saelan No.9',
                      capacity: 50,
                      rating: 4.5,
                    ),
                    RecommendationCard(
                      width: 150,
                      imagePath:
                          'https://mybalitrips.com/static/common/blog_mbt/gwk-2.jpg',
                      recommendationName: 'Lokasi L',
                      address: 'Jl. Palupi No.55',
                      capacity: 50,
                      rating: 4.5,
                    ),
                    RecommendationCard(
                      width: 150,
                      imagePath:
                          'https://cdn1.katadata.co.id/media/images/thumb/2020/07/11/2020_07_11-16_51_03_9dccdcd160129c794bab37fa7d80a98d_960x640_thumb.jpg',
                      recommendationName: 'Lokasi N',
                      address: 'Jl. Pue Bongo No.11',
                      capacity: 50,
                      rating: 4.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Parkir Terdekat',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    NearestLocationCard(
                      width: 150,
                      imagePath:
                          'https://media.istockphoto.com/id/1330046874/vector/location-flat-icon-flat-design-vector-illustration.jpg?s=612x612&w=0&k=20&c=nC6anKwSd23Uo727WdydcR_Ef3cW449ndhtT8TYwS5U=',
                      nearestLocationName: 'Lokasi S',
                      address: 'Jl. Soeprapto No.38',
                      capacity: 50,
                      rating: 4.5,
                    ),
                    NearestLocationCard(
                      width: 150,
                      imagePath:
                          'https://media.istockphoto.com/id/1330046874/vector/location-flat-icon-flat-design-vector-illustration.jpg?s=612x612&w=0&k=20&c=nC6anKwSd23Uo727WdydcR_Ef3cW449ndhtT8TYwS5U=',
                      nearestLocationName: 'Lokasi T',
                      address: 'Jl. Soeprapto No.40',
                      capacity: 50,
                      rating: 4.5,
                    ),
                    NearestLocationCard(
                      width: 150,
                      imagePath:
                          'https://media.istockphoto.com/id/1330046874/vector/location-flat-icon-flat-design-vector-illustration.jpg?s=612x612&w=0&k=20&c=nC6anKwSd23Uo727WdydcR_Ef3cW449ndhtT8TYwS5U=',
                      nearestLocationName: 'Lokasi U',
                      address: 'Jl. Soeprapto No.43',
                      capacity: 50,
                      rating: 4.5,
                    ),
                    NearestLocationCard(
                      width: 150,
                      imagePath:
                          'https://media.istockphoto.com/id/1330046874/vector/location-flat-icon-flat-design-vector-illustration.jpg?s=612x612&w=0&k=20&c=nC6anKwSd23Uo727WdydcR_Ef3cW449ndhtT8TYwS5U=',
                      nearestLocationName: 'Lokasi V',
                      address: 'Jl. Soeprapto No.45',
                      capacity: 50,
                      rating: 4.5,
                    ),
                    NearestLocationCard(
                      width: 150,
                      imagePath:
                          'https://media.istockphoto.com/id/1330046874/vector/location-flat-icon-flat-design-vector-illustration.jpg?s=612x612&w=0&k=20&c=nC6anKwSd23Uo727WdydcR_Ef3cW449ndhtT8TYwS5U=',
                      nearestLocationName: 'Lokasi W',
                      address: 'Jl. S Parman No.77',
                      capacity: 50,
                      rating: 4.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.local_parking, title: 'Parkir'),
          TabItem(icon: Icons.payment, title: 'Add'),
          TabItem(icon: Icons.history, title: 'Riwayat'),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        initialActiveIndex: pageC.pageIndex.value,
        onTap: (int i) => pageC.changePage(i),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String name;

  CategoryItem({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40, // Sesuaikan tinggi ikon agar sejajar
            child: Icon(icon, size: 32),
          ),
          SizedBox(height: 8),
          Container(
            width: 80,
            color: Colors.grey[200],
            child: Center(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final double height;
  final String imagePath;
  final String locationName;
  final String address;
  final int capacity;
  final double rating;

  LocationCard({
    required this.height,
    required this.imagePath,
    required this.locationName,
    required this.address,
    required this.capacity,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: height,
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              imagePath,
              width: 200,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            locationName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(address),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Slot Parkir: $capacity'),
              SizedBox(
                width: 10,
              ),
              Icon(Icons.star,
                  color: Color.fromARGB(255, 255, 196, 0), size: 20),
              SizedBox(width: 4),
              Text(
                rating.toString(),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final double width;
  final String recommendationName;
  final String imagePath; // Tambahkan properti imagePath
  final String address; // Tambahkan properti address
  final int capacity; // Tambahkan properti capacity
  final double rating; // Tambahkan properti rating

  RecommendationCard({
    required this.width,
    required this.recommendationName,
    required this.imagePath,
    required this.address,
    required this.capacity,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: width,
      height: 200, // Ubah tinggi menjadi 200
      title: recommendationName,
      subtitle: address, // Ganti dengan properti yang sesuai
      imagePath: imagePath, // Ganti dengan properti yang sesuai
      capacity: capacity, // Ganti dengan properti yang sesuai
      rating: rating, // Ganti dengan properti yang sesuai
    );
  }
}

class NearestLocationCard extends StatelessWidget {
  final double width;
  final String nearestLocationName;
  final String imagePath; // Tambahkan properti imagePath
  final String address; // Tambahkan properti address
  final int capacity; // Tambahkan properti capacity
  final double rating; // Tambahkan properti rating

  NearestLocationCard({
    required this.width,
    required this.nearestLocationName,
    required this.imagePath,
    required this.address,
    required this.capacity,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: width,
      height: 200, // Ubah tinggi menjadi 200
      title: nearestLocationName,
      subtitle: address, // Ganti dengan properti yang sesuai
      imagePath: imagePath, // Ganti dengan properti yang sesuai
      capacity: capacity, // Ganti dengan properti yang sesuai
      rating: rating, // Ganti dengan properti yang sesuai
    );
  }
}

class CustomCard extends StatelessWidget {
  final double width;
  final double height; // Tambahkan properti height
  final String title;
  final String subtitle;
  final String imagePath; // Tambahkan properti imagePath
  final int capacity; // Tambahkan properti capacity
  final double rating; // Tambahkan properti rating

  CustomCard({
    required this.width,
    required this.height, // Tambahkan properti height
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.capacity,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height, // Gunakan properti height
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        // color: Colors.orange,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              imagePath,
              width: 200,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(subtitle),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Slot Parkir: $capacity'),
              SizedBox(
                width: 10,
              ),
              Icon(Icons.star,
                  color: Color.fromARGB(255, 255, 196, 0), size: 20),
              SizedBox(width: 4),
              Text(
                rating.toString(),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ParkingView(),
  ));
}

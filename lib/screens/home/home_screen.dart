import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:gustoro/screens/home/vip_resto.dart';
import '../../shared/app_colors.dart';
import '../../shared/drawer.dart';
import '../../shared/drawer_admin.dart';
import 'detail_resturant.dart';
import 'widgets_home/card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _restaurants = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredRestaurants = [];
  bool showFastFood = true;
  bool showFineDining = true;
  bool showCafe = true;
  bool showCasualDining = true;
  bool showBuffet = true;
  bool showBistro = true;
  bool showPizzeria = true;
  bool showFoodTruck = true;
  bool showSushiBar = true;

  bool showVeganVegetarian = true;
  bool showEthnicCuisine = true;
  bool showWineBar = true;
  bool showSportsBar = true;
  bool showFamilyStyle = true;
  bool showPopUpRestaurant = true;
  final _secureStorage = const FlutterSecureStorage();
  String? _userEmail;

  @override
  void initState() {
    super.initState();

    _fetchRestaurants();
    _searchController.addListener(_filterRestaurants);
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await _secureStorage.read(key: 'email');
    setState(() {
      _userEmail = email;
    });
  }

  void _fetchRestaurants() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('isActive', isEqualTo: true)
          .get();

      setState(() {
        _restaurants = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final GeoPoint? location = data['location'];

          // Safely cast menu field to List<Map<String, dynamic>> or an empty list
          List<Map<String, dynamic>> menuItems = [];
          if (data['menu'] != null) {
            // Check if the 'menu' is actually a list and cast it
            menuItems = List<Map<String, dynamic>>.from(data['menu']);
          }

          return {
            'id': doc.id, // Store the document ID here
            'image': data['image'] ?? '',
            'locationName': data['locationName'] ?? 'Unknown Location',
            'name': data['name'] ?? 'Unknown Name',
            'description': data['description'] ?? 'No description provided',
            'emailAdmin': data['emailAdmin'] ?? 'No email available',
            'type': data['type'] ?? 'Unknown Type',
            'latitude': location?.latitude,
            'longitude': location?.longitude,
            'socialMedia': data['socialMedia'],
            'menu': menuItems, // Use the correctly typed menuItems
            'isVip': data['isVip'],
            'phone': data['phone'],
            'isDelivery': data['isDelivery'],
          };
        }).toList();

        _filteredRestaurants = _restaurants;
      });
    } catch (e) {
      // Handle errors here.
      // print("Error fetching restaurants: $e");
    }
  }

  void _filterRestaurants() {
    String query = _searchController.text.toLowerCase();

    // Mapping restaurant types to Arabic equivalents
    Map<String, String> typeTranslations = {
      'Fast Food': 'وجبات سريعة',
      'Fine Dining': 'مطعم فاخر',
      'Cafe': 'مقهى',
      'Casual Dining': 'مطعم عادي',
      'Buffet': 'بوفيه',
      'Bistro': 'مطعم صغير',
      'Pizzeria': 'بيتزا',
      'Food Truck': 'عربة طعام',
      'Sushi Bar': 'سوشي',
      'Vegan/Vegetarian': 'نباتي',
      'Ethnic Cuisine': 'مأكولات عالمية',
      'Wine Bar': 'بار مشروبات',
      'Sports Bar': 'بار رياضي',
      'Family Style': 'مطعم عائلي',
      'Pop-Up Restaurant': 'مطعم مؤقت',
    };

    setState(() {
      _filteredRestaurants = _restaurants.where((restaurant) {
        final name = restaurant['name'].toString().toLowerCase();
        final type = restaurant['type'].toString();
        final location = restaurant['locationName'].toString().toLowerCase();

        // Get the Arabic translation of the type
        final translatedType = typeTranslations[type] ?? '';

        final matchesSearchName = name.contains(query);
        final matchesSearchType = type.toLowerCase().contains(query) ||
            translatedType.contains(query);
        final matchesSearchLoc = location.contains(query);

        final matchesType = (showFastFood && type == 'Fast Food') ||
            (showFineDining && type == 'Fine Dining') ||
            (showCafe && type == 'Cafe') ||
            (showCasualDining && type == 'Casual Dining') ||
            (showBuffet && type == 'Buffet') ||
            (showBistro && type == 'Bistro') ||
            (showPizzeria && type == 'Pizzeria') ||
            (showFoodTruck && type == 'Food Truck') ||
            (showSushiBar && type == 'Sushi Bar') ||
            (showVeganVegetarian && type == 'Vegan/Vegetarian') ||
            (showEthnicCuisine && type == 'Ethnic Cuisine') ||
            (showWineBar && type == 'Wine Bar') ||
            (showSportsBar && type == 'Sports Bar') ||
            (showFamilyStyle && type == 'Family Style') ||
            (showPopUpRestaurant && type == 'Pop-Up Restaurant') ||
            (!showFastFood &&
                !showFineDining &&
                !showCafe &&
                !showCasualDining &&
                !showBuffet &&
                !showBistro &&
                !showPizzeria &&
                !showFoodTruck &&
                !showSushiBar &&
                !showVeganVegetarian &&
                !showEthnicCuisine &&
                !showWineBar &&
                !showSportsBar &&
                !showFamilyStyle &&
                !showPopUpRestaurant);

        return (matchesSearchName || matchesSearchType || matchesSearchLoc) &&
            matchesType;
      }).toList();
    });
  }

  void _updateCheckboxState({
    bool? fastFood,
    bool? fineDining,
    bool? cafe,
    bool? casualDining,
    bool? buffet,
    bool? bistro,
    bool? pizzeria,
    bool? foodTruck,
    bool? sushiBar,
    bool? veganVegetarian,
    bool? ethnicCuisine,
    bool? wineBar,
    bool? sportsBar,
    bool? familyStyle,
    bool? popUpRestaurant,
  }) {
    setState(() {
      if (fastFood != null) showFastFood = fastFood;
      if (fineDining != null) showFineDining = fineDining;
      if (cafe != null) showCafe = cafe;
      if (casualDining != null) showCasualDining = casualDining;
      if (buffet != null) showBuffet = buffet;
      if (bistro != null) showBistro = bistro;
      if (pizzeria != null) showPizzeria = pizzeria;
      if (foodTruck != null) showFoodTruck = foodTruck;
      if (sushiBar != null) showSushiBar = sushiBar;
      if (veganVegetarian != null) showVeganVegetarian = veganVegetarian;
      if (ethnicCuisine != null) showEthnicCuisine = ethnicCuisine;
      if (wineBar != null) showWineBar = wineBar;
      if (sportsBar != null) showSportsBar = sportsBar;
      if (familyStyle != null) showFamilyStyle = familyStyle;
      if (popUpRestaurant != null) showPopUpRestaurant = popUpRestaurant;
    });
    _filterRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _userEmail == "hero90@gmail.com"
          ? const CustomDrawerAdmin()
          : const CustomDrawerUser(),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 250,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name & location name...'.tr,
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: accentColor),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                showMenu(
                  color: mainColor,
                  context: context,
                  position: const RelativeRect.fromLTRB(100, 80, 100, 100),
                  items: [
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Fast Food".tr),
                        value: showFastFood,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(fastFood: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Fine Dining".tr),
                        value: showFineDining,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(fineDining: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Cafe".tr),
                        value: showCafe,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(cafe: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Casual Dining".tr),
                        value: showCasualDining,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(casualDining: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Buffet".tr),
                        value: showBuffet,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(buffet: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Bistro".tr),
                        value: showBistro,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(bistro: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Pizzeria".tr),
                        value: showPizzeria,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(pizzeria: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Food Truck".tr),
                        value: showFoodTruck,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(foodTruck: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Sushi Bar".tr),
                        value: showSushiBar,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(sushiBar: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Vegan/Vegetarian".tr),
                        value: showVeganVegetarian,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(veganVegetarian: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Ethnic Cuisine".tr),
                        value: showEthnicCuisine,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(ethnicCuisine: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Wine Bar".tr),
                        value: showWineBar,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(wineBar: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Sports Bar".tr),
                        value: showSportsBar,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(sportsBar: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Family Style".tr),
                        value: showFamilyStyle,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(familyStyle: value);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: CheckboxListTile(
                        activeColor: accentColor,
                        title: Text("Pop-Up Restaurant".tr),
                        value: showPopUpRestaurant,
                        onChanged: (value) {
                          Navigator.pop(context);
                          _updateCheckboxState(popUpRestaurant: value);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: mainColor,
      // ignore: unnecessary_null_comparison
      body: _filteredRestaurants == null || _filteredRestaurants.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No restaurants found.'.tr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                VipRestaurantsList(),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "All Restaurants".tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.restaurant,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = _filteredRestaurants[index];
                      final restaurantId = restaurant[
                          'id']; // Assuming 'id' is the key for restaurant ID

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailPage(
                                restaurant: restaurant,
                                id: restaurantId,
                              ),
                            ),
                          );
                        },
                        child: CardItem(
                          imageUrl: restaurant['image'],
                          info: restaurant['locationName'],
                          title: restaurant['name'],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

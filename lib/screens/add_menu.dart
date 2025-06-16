import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gustoro/shared/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class AddMenuPage extends StatefulWidget {
  final String emailAdmin;

  const AddMenuPage({Key? key, required this.emailAdmin}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddMenuPageState createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _dialogFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceAfterDiscountController =
      TextEditingController();
  bool _hasDiscount = false;
  late DocumentReference restaurantDocRef;
  bool isInitialized = false;
  List<dynamic> menuItems = [];

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  File? _dialogSelectedImage;
  bool _isLoading = false;

  // Dialog-specific controllers
  final TextEditingController _dialogNameController = TextEditingController();
  final TextEditingController _dialogPriceController = TextEditingController();
  final TextEditingController _dialogPriceAfterDiscountController =
      TextEditingController();
  bool _dialogHasDiscount = false;

  Future<void> _initializeRestaurant() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('emailAdmin', isEqualTo: widget.emailAdmin)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      restaurantDocRef = querySnapshot.docs.first.reference;
      await _fetchMenuItems();
      setState(() {
        isInitialized = true;
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant not found!')),
      );
    }
  }

  Future<void> _fetchMenuItems() async {
    final docSnapshot = await restaurantDocRef.get();
    final data = docSnapshot.data() as Map<String, dynamic>?;

    menuItems = data?['menu'] ?? [];
    setState(() {});
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('menu_images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await storageRef.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
      return null;
    }
  }

  Future<void> _addMenuItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String name = _nameController.text.trim();
      final double? price = double.tryParse(_priceController.text.trim());
      final double? priceAfterDiscount = _hasDiscount
          ? double.tryParse(_priceAfterDiscountController.text.trim())
          : null;

      if (price != null && (!_hasDiscount || priceAfterDiscount != null)) {
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await _uploadImage(_selectedImage!);
        }

        try {
          // Creating a new menu item as a map
          final newItem = {
            'name': name,
            'price': price,
            'hasDiscount': _hasDiscount,
            'priceAfterDiscount': _hasDiscount ? priceAfterDiscount : null,
            'imageUrl': imageUrl,
          };

          // Assuming you fetch and update the menuItems from Firestore
          menuItems.add(newItem);
          await restaurantDocRef
              .update({'menu': menuItems}); // Storing in Firestore

          _nameController.clear();
          _priceController.clear();
          _priceAfterDiscountController.clear();
          setState(() {
            _hasDiscount = false;
            _selectedImage = null;
          });

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Menu item added successfully!'.tr)),
          );
        } catch (e) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add menu item: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid input')),
        );
      }
    }
  }

  Future<void> _pickImage(bool isDialog) async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isDialog) {
          _dialogSelectedImage = File(pickedFile.path);
        } else {
          _selectedImage = File(pickedFile.path);
        }
      });
    }
  }

  void _showEditDialog(int index) {
    final item = menuItems[index];

    _dialogNameController.text = item['name'];
    _dialogPriceController.text = item['price'].toString();
    _dialogPriceAfterDiscountController.text =
        item['priceAfterDiscount']?.toString() ?? '';
    _dialogHasDiscount = item['hasDiscount'];
    _dialogSelectedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: mainColor,
          title: Text('Edit Menu Item'.tr),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: _dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _dialogNameController,
                      decoration: InputDecoration(
                        labelText: 'Menu Item Name'.tr,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the item name'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dialogPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price'.tr,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the price'.tr;
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _dialogHasDiscount,
                          onChanged: (value) {
                            setState(() {
                              _dialogHasDiscount = value ?? false;
                            });
                          },
                        ),
                        Text('Has Discount'.tr),
                      ],
                    ),
                    if (_dialogHasDiscount)
                      TextFormField(
                        controller: _dialogPriceAfterDiscountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price After Discount'.tr,
                        ),
                        validator: (value) {
                          if (_dialogHasDiscount &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter the price after discount'.tr;
                          }
                          if (_dialogHasDiscount &&
                              double.tryParse(value ?? '') == null) {
                            return 'Please enter a valid number'.tr;
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor),
                      onPressed: () => _pickImage(true),
                      child: Text(
                        'Choose Image'.tr,
                        style: TextStyle(
                            color: mainColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_dialogSelectedImage != null)
                      Image.file(
                        _dialogSelectedImage!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel'.tr,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_dialogFormKey.currentState?.validate() ?? false) {
                  String? newImageUrl = item['imageUrl'];
                  if (_dialogSelectedImage != null) {
                    newImageUrl = await _uploadImage(_dialogSelectedImage!);
                  }

                  final updatedItem = {
                    'name': _dialogNameController.text.trim(),
                    'price':
                        double.tryParse(_dialogPriceController.text.trim()) ??
                            0.0,
                    'hasDiscount': _dialogHasDiscount,
                    'priceAfterDiscount': _dialogHasDiscount
                        ? double.tryParse(
                            _dialogPriceAfterDiscountController.text.trim())
                        : null,
                    'imageUrl': newImageUrl,
                  };

                  setState(() {
                    menuItems[index] = updatedItem;
                  });
                  await restaurantDocRef.update({'menu': menuItems});
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Menu item updated!'.tr)),
                  );
                }
              },
              child: Text(
                'Save'.tr,
                style:
                    TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeRestaurant();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Center(
        child: CircularProgressIndicator(
          color: accentColor,
        ),
      );
    }

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: mainColor,
        title:  Text('Add Menu Items'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration:  InputDecoration(
                    labelText: 'Menu Item Name'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the item name'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration:  InputDecoration(
                    labelText: 'Price'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price'.tr;
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _hasDiscount,
                      onChanged: (value) {
                        setState(() {
                          _hasDiscount = value ?? false;
                        });
                      },
                    ),
                     Text('Has Discount'.tr),
                  ],
                ),
                if (_hasDiscount)
                  TextFormField(
                    controller: _priceAfterDiscountController,
                    keyboardType: TextInputType.number,
                    decoration:  InputDecoration(
                      labelText: 'Price After Discount'.tr,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_hasDiscount && (value == null || value.isEmpty)) {
                        return 'Please enter the price after discount'.tr;
                      }
                      if (_hasDiscount &&
                          double.tryParse(value ?? '') == null) {
                        return 'Please enter a valid number'.tr;
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: accentColor),
                    onPressed: () => _pickImage(false),
                    child: Text('Choose Image'.tr,
                        style: TextStyle(
                            color: mainColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: accentColor),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await _addMenuItem();
                            setState(() {
                              _isLoading = false;
                            });
                          },
                    child: Text(
                      'Add Menu Item'.tr,
                      style: TextStyle(
                          color: mainColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                 Text(
                  'Menu Items'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return ListTile(
                      leading: item['imageUrl'] != null
                          ? Image.network(
                              item['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.fastfood,
                              size: 50,
                            ),
                      title: Text(item['name']),
                      subtitle: Text(
                        item['hasDiscount'] == null
                            ? '\$${item['price']}'
                            : item['hasDiscount']
                                ? '\$${item['priceAfterDiscount']} (was \$${item['price']})'
                                : '\$${item['price']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: accentColor),
                            onPressed: () {
                              _showEditDialog(index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMenuItem(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteMenuItem(int index) async {
    try {
      menuItems.removeAt(index);
      await restaurantDocRef.update({'menu': menuItems});
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Menu item deleted successfully!'.tr)),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete menu item: $e')),
      );
    }
  }
}

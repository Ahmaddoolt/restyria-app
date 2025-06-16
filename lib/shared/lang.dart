import 'package:get/get.dart';

class Lang extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar': {
          "None": 'لا يوجد',
          'Resturants Active': "تفعيل المطاعم",
          "Sign In": "تسجيل دخول",
          "Email...": "الايميل",
          "Password...": "كلمة المرور",
          "LOGIN": "تسجيل دخول",
          "Create a new Account": "انشاء حساب جديد",
          'Login successful!': "تم تسجيل الدخول بنجاح",
          'Invalid email or password': "خطأ بالمدخلات",
          'Please fill in all fields': "الرجاء ادخال جميع المعطيات",
          'Passwords do not match': "كلمة المرور لا تتطابق",
          "Email is already registered": "الايميل موجود سابقا",
          "Signup successful!": "تم انشاء الحساب بنجاح",
          'Sign Up': "انشاء حساب",
          'SIGN UP': "انشاء حساب",
          'Phone Number...': "رقم الجوال",
          'Confirm Password...': "تأكيد كلمة المرور",
          "Already have an account? ": " هل لديك حساب بالفعل ؟ ",
          //drawrr

          'Home': "الصفحة الرئيسية",
          'Create Restaurant': "انشاء مطعم",
          'My Restaurant': "مطعمي",
          'Unable to retrieve email. Please try again.':
              "هنالك مشكلة في الاتصال",
          'Vip Restaurant': "ترقية المطعم",
          'Messages': "الرسائل",
          'Language': "اللغة",
          'Logout': "تسجيل خروج",
          'Vip Requests': "طلبات ترقية المطعم",
          // home screen
          'Search by name & location name...': "البحث عن طريق الاسم & الموقع",
          'No restaurants found.': "لم يتم ايجاد مطاعم",
          "VIP Restaurants": "المطاعم المميزة",
          "All Restaurants": "جميع المطاعم",
          "No VIP Restaurants Yet": "لا يوجد مطاعم مميزة بعد",

          // detail res
          'Description:': "وصف المطعم",
          'View on Map': "عرض على الخريطة",
          'View Menu': "عرض قائمة الطعام",
          'Reservation': "حجز طاولة",
          'Restaurant Location': "موقع المطعم",
          'Menu Items': "قائمة الطعام",
          'Image': "صورة",
          'Name': "الاسم",
          'Price': "السعر",
          'AfterDis%': "بعد الخصم",

          'Please select a day and time slot': "الرجاء اختيار توقيت و يوم",
          'Please fill out all fields': "الرجاء ادخال جميع الحقول",
          'Reservation request sent successfully': "تم ارسال الطلب بنجاح",
          'Reservation Request': "حجز موعد",
          'Your Name': "الاسم الثلاثي",
          'Phone Number': "رقم الهاتف",
          'Number of Persons': "عدد الأشخاص",
          'Select a day': "اختر يوم",
          'Select a time slot': "اختر توقيت",
          'Additional Message (Optional)':
              "معلومات هامة لم يتم أخذها ؟ (اختياري)",
          'Send Reservation Request': "ارسال طلب الحجز",

          //create res
          'Please select an image for the restaurant.':
              "الرجاء ادخال صورة للمطعم",
          'Please select a location and enter its name.': "الرجاء ادخال الموقع",
          'You can only create one restaurant.': "يمكنك فقط انشاء مطعم واحد",
          'Restaurant created successfully!': "تم انشاء المطعم بنجاح",
          'Restaurant Name': "اسم المطعم",
          'Please enter a name': "الرجاء ادخال اسم  المطعم",
          'Description': "وصف المطعم",
          'Please enter a description': "الرجاء ادخال وصف المطعم",
          'Location Name': "اسم الموقع",
          'Please enter the location name': "الرجاء ادخال اسم الموقع",
          'Please enter the Phone Number': "الرجاء ادخال رقم هاتف المطعم",
          'Social Media Link (Optional)': "رابط سوشال ميديا (اختياري)",
          'Restaurant Type': "نوع المطعم",
          'Please select a type': "الرجاء اختيار نوع المطعم",
          'Select Location on Map': "اختيار موقع على الخريطة",
          'Change Location': "تغيير الموقع على الخريطة",

          //own res
          'Edit Description': "تعديل المطعم",
          'Restaurant Description': "وصف المطعم",
          'Enter the new description': "ادخل الوصف الجديد",
          'Cancel': "الغاء",
          'Save': "حفظ",
          'Description updated successfully': "تم تحديث الوصف بنجاح",
          'Edit Restaurant Type': "تعديل نوع المطعم",
          'Restaurant type updated successfully': "تم تحديث نوع المطعم بنجاح",
          'Edit Social Media Link': "تعديل سوشال ميديا",
          'Social Media Link': "سوشال ميديا",
          'Enter the new social media link': "ادخل سوشال ميديا جديد",
          'Social Media link updated successfully':
              "تم تحديث السوشال ميديا بنجاح",
          'Edit Name': "تعديل الاسم",
          'Enter the new name': "ادخل الاسم الجديد",
          'Name updated successfully': "تم تحديث الاسم بنجاح",
          'Edit phone number': "تعديل رقم هاتف المطعم",
          'Enter the new number': "ادخل الرقم الجديد",
          'phone number updated successfully': "تم تحديث رقم الهاتف بنجاح",
          'Location updated successfully': "تم تحديث الموقع بنجاح",
          'Edit Location Name': "تعديل اسم الموقع",
          'No restaurant found for the given email': "لا يوجد مطعم خاص بك",
          'No restaurant found for this email.': "لا يوجد مطعم خاص بك",
          'No image selected': "لم يتم اختيار صورة",
          'Uploading image...': "تحميل الصورة",
          'Image updated successfully': "تم تحديث الصورة بنجاح",
          'Restaurant Details': "تفاصيل المطعم",
          'Add Menu': "اضافة قائمة طعام",
          'Reservations': "حجوزات المطعم",

          //vip request
          'You have already submitted a VIP request.':
              "لقد تم ارسال طلبك بالفعل",
          'VIP request submitted successfully!': "تم ارسال الطلب بنجاح",
          'Request VIP Restaurant': " 'طلب ترقية المطعم",
          'Request to make your restaurant VIP':
              "ارسال طلب لجعل مطعمك ضمن قائمة المطاعم المميزة",
          'Enter your offer to apply for this request with an effective means of contact':
              "قم بكتابة طلبك لجعل مطعمك مميز",
          'Submit VIP Request': "ارسال الطلب",

          //messegs
          'Message deleted successfully!': "تم حذف الرسالة بنجاح",
          'No messages available.': "لا يوجد رسائل حاليا",

          //add menu
          'Menu item added successfully!': "تم اضافة العنصر بنجاح الى القائمة",
          'Edit Menu Item': "التعديل على العنصر",
          'Menu Item Name': "اسم العنصر",
          'Please enter the item name': "الرجاء ادخال اسم العنصر",
          'Please enter the price': "الرجاء ادخال السعر",
          'Please enter a valid number': "الرجاء ادخال رقم",
          'Has Discount': "يوجد خصم",
          'Price After Discount': "السعر بعد الخصم",
          'Please enter the price after discount':
              "الرجاء ادخال السعر بعد الخصم",
          'Choose Image': "اختيار صورة",
          'Menu item updated!': "تم تعديل العنصر",
          'Add Menu Items': "اضافة عناصر الى القائمة",
          'Add Menu Item': "اضافة العنصر",
          'Menu item deleted successfully!': "تم حذف العنصر بنجاح",

          // vip approve deapprove
          'Reservation approved and user notified.': "تم الموافقة على الطلب",
          'Reservation rejected and user notified.': "تم رفض الطلب",
          'No reservations found.': "لا يوجد طلبات حاليا",
          'No VIP requests available.': "لا يوجد طلبات حاليا",
          'Approve': "قبول",
          'Reject': "رفض",
          'Restaurant marked as VIP successfully!': "تم ترقية المطعم بنجاح",
          'VIP Requests': "طلبات الترقية",
          'Restaurant details not found': "لم يتم ايجاد تفاصيل المطعم",
          'Make VIP': "ترقية",

          'Restaurant VIP status removed successfully!':
              "تم ازالة الترقية بنجاح",
          'No VIP restaurants available.': "لا يوجد مطاعم مميزة حاليا",
          'Remove VIP': "ازالة الترقية",

          // res sche
          "Restaurant Schedule": "جدول المطعم",
          'Time Slots': "التوقيت",
          'Fast Food': "وجبات سريعة",
          'Fine Dining': "طعام فاخر",
          'Cafe': "مقهى",
          'Casual Dining': "طعام غير رسمي",
          'Buffet': "بوفيه",
          'Bistro': "بيسترو",
          'Pizzeria': "مطعم بيتزا",
          'Food Truck': "شاحنة طعام",
          'Sushi Bar': "مطعم سوشي",
          'Vegan/Vegetarian': "نباتي / نباتي صرف",
          'Ethnic Cuisine': "مأكولات عالمية",
          'Wine Bar': "بار نبيذ",
          'Sports Bar': "بار رياضي",
          'Family Style': "مطعم عائلي",
          'Pop-Up Restaurant': "مطعم مؤقت",
          'Type': 'النوع',
          'Phone': 'رقم الهاتف',
          'Delivery?': 'التوصيل؟',
          'Yes': 'نعم',
          'No': 'لا',

          'Unknown Location': 'الموقع غير معروف',
          'Unknown Type': 'النوع غير معروف',
          'Unknown phone': 'الهاتف غير معروف',
          'Could not open the link:': 'تعذر فتح الرابط:',
          'Invalid URL format': 'تنسيق الرابط غير صالح',

          "Is there delivery?" : "هل يوجد توصيل ؟",
        },
      };
}

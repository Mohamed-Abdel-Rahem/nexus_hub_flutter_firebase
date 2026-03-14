import 'package:flutter/material.dart';
import 'package:nexus_hub_flutter_firebase/model/user_model.dart';
import 'package:nexus_hub_flutter_firebase/services/firestore_service.dart';

class DataRead extends StatefulWidget {
  const DataRead({super.key});

  @override
  State<DataRead> createState() => _DataReadState();
}

class _DataReadState extends State<DataRead> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    UserModel? fetchedUser = await FirestoreService.instance
        .readDataFromFirestore(context: context);

    if (mounted) {
      setState(() {
        user = fetchedUser;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // خلفية بيضاء صافية
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // هنضيف هنا الـ Logout لاحقاً
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.black54),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // حركة ناعمة في السكرول
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // قسم الصورة الشخصية
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4), // بوردر حول الصورة
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent,
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(
                              Icons.person_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // أيقونة التعديل (شكل جمالي حالياً)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الاسم والإيميل بشكل مركزي
                  Text(
                    user?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // قسم المعلومات المفصلة (بدون باسوورد أو UID)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Account Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileItem(
                          icon: Icons.badge_outlined,
                          title: "Display Name",
                          value: user?.name ?? "N/A",
                        ),
                        _buildProfileItem(
                          icon: Icons.alternate_email_rounded,
                          title: "Email Address",
                          value: user?.email ?? "N/A",
                        ),
                        // ممكن تضيف هنا حقول تانية لو ضفتها للموديل (زي الموبايل)
                        _buildProfileItem(
                          icon: Icons.verified_user_outlined,
                          title: "Account Status",
                          value: "Active Member",
                          textColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ويدجيت محسنة لعرض المعلومات
  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 16),
          // التعديل هنا: حطينا الـ Column جوه Expanded
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.black87,
                  ),
                  overflow: TextOverflow
                      .ellipsis, // لو النص لسه طويل جداً هيحط ثلاث نقط (...)
                  maxLines:
                      1, // أو ممكن تخليه 2 لو عايز الاسم يظهر كامل في سطرين
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

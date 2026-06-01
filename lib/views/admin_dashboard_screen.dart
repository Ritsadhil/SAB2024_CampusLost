import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color bgLight = const Color(0xFFF9F9FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.black87, size: 20),
          ),
        ),
        title: Row(
          children: [
            const Text(
              'CampusLost',
              style: TextStyle(
                color: Color(0xFF2962FF),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: SYSTEM OVERVIEW ---
            const Text(
              "System Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildOverviewTopCard(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildOverviewSubCard(Icons.check_circle_outline, Colors.blue, "Resolved", "1,284")),
                const SizedBox(width: 12),
                Expanded(child: _buildOverviewSubCard(Icons.people_outline, Colors.grey.shade700, "Total Users", "8,491")),
              ],
            ),
            const SizedBox(height: 24),

            // --- SECTION 2: MODERASI LAPORAN ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Moderasi Laporan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("View All", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildModerationCard(
              title: "Black iPhone 13",
              flagText: "FLAGGED: SPAM",
              flagColor: Colors.orange.shade800,
              flagBgColor: Colors.orange.shade100,
              desc: "Reported by 3 users for irrelevant content. User history shows multiple duplicate posts in the last",
              userInfo: "Posted by User ID: #9921  •  2 hrs ago",
              imgUrl: "https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?auto=format&fit=crop&w=300&q=80",
              btn1Text: "Keep Visible",
              btn2Text: "Hide & Warn",
            ),
            const SizedBox(height: 16),
            _buildModerationCard(
              title: "Silver Hydroflask",
              flagText: "FLAGGED: INAPPROPRIATE",
              flagColor: Colors.orange.shade800,
              flagBgColor: Colors.orange.shade100,
              desc: "Description contains offensive language. Automated filter caught potential policy...",
              userInfo: "Posted by User ID: #1042  •  5 hrs ago",
              imgUrl: "https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=300&q=80",
              btn1Text: "Edit Details",
              btn2Text: "Delete",
            ),
            const SizedBox(height: 24),

            // --- SECTION 3: VERIFIKASI MANUAL ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Verifikasi Manual",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "4 Pending",
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildVerificationItem(
                    avatarInitials: "JD",
                    avatarColor: Colors.blue.shade100,
                    name: "John Doe",
                    itemName: "MacBook Pro Charger",
                    proofText: '"I have the serial number ending in 4592, and a scratch on the bottom left corner as shown in my attached photo."',
                    hasAttachment: true,
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildVerificationItem(
                    avatarInitials: "AS",
                    avatarColor: Colors.orange.shade100,
                    name: "Anna Smith",
                    itemName: "Library Keys (Room 4B)",
                    proofText: '"I am the TA for Room 4B. My faculty ID matches the tag color mentioned in the description."',
                    hasAttachment: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'My Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildOverviewTopCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "+12% today",
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text("Active Reports", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 4),
          const Text("342", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOverviewSubCard(IconData icon, Color iconColor, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildModerationCard({
    required String title,
    required String flagText,
    required Color flagColor,
    required Color flagBgColor,
    required String desc,
    required String userInfo,
    required String imgUrl,
    required String btn1Text,
    required String btn2Text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Accent Line
              Container(width: 4, color: Colors.orange),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Placeholder
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                          image: NetworkImage(imgUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: flagBgColor, borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  flagText,
                                  style: TextStyle(color: flagColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(userInfo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(btn1Text, style: const TextStyle(color: Colors.black87)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC62828), // Dark Red
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (btn2Text == "Delete") const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                                        if (btn2Text == "Delete") const SizedBox(width: 4),
                                        Text(btn2Text, style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationItem({
    required String avatarInitials,
    required Color avatarColor,
    required String name,
    required String itemName,
    required String proofText,
    required bool hasAttachment,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarColor,
                radius: 16,
                child: Text(
                  avatarInitials,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(text: "$name ", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: "claims\n", style: TextStyle(color: Colors.grey)),
                      TextSpan(text: itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PROOF SUBMITTED",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(proofText, style: const TextStyle(fontSize: 13, height: 1.4)),
                if (hasAttachment) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.attachment, size: 14, color: primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        "View 1 Attachment",
                        style: TextStyle(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC62828)), // Red border
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Reject", style: TextStyle(color: Color(0xFFC62828))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Approve Claim", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
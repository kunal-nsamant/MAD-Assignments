import 'package:flutter/material.dart';

void main() {
  // my personal info object with all my contact details
  UserInfo user = UserInfo(
    name: 'Kunal Nilesh Samant',
    position: 'Data Engineer',
    company: 'Formula 1',
    phone: '(872) 279-7763',
    email: 'ksamant@hawk.iit.edu',
    address1: '401 E 32nd Street',
    address2: 'Chicago, IL 60616',
  );

  // my educational background for both graduate and undergrad
  user.addEducation(
    logo: 'assets/images/iitlogo.jpg',
    name: 'Illinois Institute of Technology',
    gpa: 4.0,
    degree: 'MCS',
  );
  user.addEducation(
    logo: 'assets/images/unilogo.jpeg',
    name: 'Mumbai University',
    gpa: 4.0,
    degree: 'BE COMP',
  );

  // my projects with descriptions and images
  user.addProject(ProjectInfo(
    name: 'Volleyball Player Analysis',
    description: 'Developed a high-accuracy volleyball player performance predictor using web-scraped stats, advanced regression validation, and interactive Tableau dashboards for actionable athletic insights.',
    imageUrl: 'assets/images/project1.png',
  ));
  user.addProject(ProjectInfo(
    name: 'Interactive Music Catalog & Analysis',
    description: 'Built an interactive music catalog with SQL and Python, enabling detailed user behavior analysis and genre insights through Power BI dashboards and efficient GUI-driven data management.',
    imageUrl: 'assets/images/project2.png',
  ));
  user.addProject(ProjectInfo(
    name: 'Automated Vendor Analytics & Reporting System',
    description: 'Developed automated reporting and analytics pipelines using SQL, Azure, and Airflow, delivering vendor insights and operational improvements through Power BI dashboards and scalable data solutions.',
    imageUrl: 'assets/images/project3.png',
  ));
  user.addProject(ProjectInfo(
    name: 'Salon Analytics',
    description: 'Built scalable ETL pipelines and dashboards to deliver insights on customer trends and stylist performance for franchise operations.',
    imageUrl: 'assets/images/project4.png',
  ));
  user.addProject(ProjectInfo(
    name: 'Multi-Class ML Inference & Explainability',
    description: 'Built and deployed optimized LightGBM/CatBoost models with SHAP-based insights, improving recall and enabling real-time, transparent multi-class predictions.',
    imageUrl: 'assets/images/project5.png',
  ));

  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProfileApp(user: user));
}

// DATA MODEL CLASSES

// data classes that hold all the user information
class UserInfo {
  final String name;
  final String position;
  final String company;
  final String phone;
  final String email;
  final String address1;
  final String address2;

  // These lists will store my education and project information
  final List<({String logo, String name, double gpa, String degree})> education = [];
  final List<ProjectInfo> projects = [];

  UserInfo({
    required this.name,
    required this.position,
    required this.company,
    required this.phone,
    required this.email,
    required this.address1,
    required this.address2,
  });

  // Method to add education entries to my profile
  void addEducation({
    required String logo,
    required String name,
    required double gpa,
    required String degree,
  }) {
    education.add((logo: logo, name: name, gpa: gpa, degree: degree));
  }

  // Method to add project entries to my profile
  void addProject(ProjectInfo project) {
    projects.add(project);
  }
}

// This class holds information about each individual project
class ProjectInfo {
  final String name;
  final String description;
  final String imageUrl;

  ProjectInfo({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

// MAIN APP WIDGET AND THEME CONFIGURATION

// main app widget that sets up the overall theme and styling
class ProfileApp extends StatelessWidget {
  final UserInfo user;

  const ProfileApp({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Professional Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Using blue as my primary color scheme
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        
        // Setting up text styles for different headings and body text
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        
        // Making all cards have consistent rounded corners and shadows
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: UserInfoPage(user: user),
    );
  }
}

// MAIN PAGE LAYOUT AND STRUCTURE

// main page that displays all my profile information
class UserInfoPage extends StatelessWidget {
  final UserInfo user;

  const UserInfoPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The app bar shows my name at the top
      appBar: AppBar(
        title: Text(user.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      
      // Light gray background for the whole screen
      backgroundColor: Colors.grey[100],
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My profile picture and basic info section
            HeaderSection(user: user),
            const SizedBox(height: 20),
            
            // phone, email, address information
            SectionCard(
              title: 'Contact Information',
              icon: Icons.contact_phone,
              child: ContactSection(user: user),
            ),
            const SizedBox(height: 20),
            
            // my educational background
            SectionCard(
              title: 'Education',
              icon: Icons.school,
              child: EducationSection(education: user.education),
            ),
            const SizedBox(height: 20),
            
            // All my projects displayed in a list
            SectionCard(
              title: 'Projects',
              icon: Icons.work,
              child: ProjectsSection(projects: user.projects),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// REUSABLE SECTION CARD COMPONENT

// creates those blue header sections for each category
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SectionCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// HEADER SECTION WITH PROFILE PICTURE AND BASIC INFO

// profile pic, name, job title and company
class HeaderSection extends StatelessWidget {
  final UserInfo user;

  const HeaderSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
          
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  'assets/images/profilepic.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // If image fails to load, show a person icon instead
                    return Container(
                      color: Colors.blue[100],
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 20),
            
            // my name, posittion and company info.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.position,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.company,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// CONTACT INFORMATION SECTION

// displaying my phone number, email and address in rows
class ContactSection extends StatelessWidget {
  final UserInfo user;

  const ContactSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContactRow(
          icon: Icons.phone,
          text: user.phone,
          iconColor: Colors.green,
        ),
        const SizedBox(height: 12),
        ContactRow(
          icon: Icons.email,
          text: user.email,
          iconColor: Colors.blue,
        ),
        const SizedBox(height: 12),
        ContactRow(
          icon: Icons.location_on,
          text: '${user.address1}\n${user.address2}',
          iconColor: Colors.red,
        ),
      ],
    );
  }
}

// creating individual contact information rows with icons
class ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const ContactRow({
    Key? key,
    required this.icon,
    required this.text,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

// EDUCATION SECTION WITH SCHOOL DETAILS

// listing all my educational qualifications
class EducationSection extends StatelessWidget {
  final List<({String logo, String name, double gpa, String degree})> education;

  const EducationSection({Key? key, required this.education}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: education
          .map((edu) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EducationTile(education: edu),
              ))
          .toList(),
    );
  }
}

// Individual education entry with school logo, name, degree and GPA
class EducationTile extends StatelessWidget {
  final ({String logo, String name, double gpa, String degree}) education;

  const EducationTile({Key? key, required this.education}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
        
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                education.logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                
                  return const Icon(
                    Icons.school,
                    color: Colors.orange,
                    size: 25,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // School name and degree information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  education.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  education.degree,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          // GPA badge with green background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${education.gpa}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PROJECTS SECTION WITH LISTVIEW

// displaying all projects in a scrollable ListView layout
class ProjectsSection extends StatelessWidget {
  final List<ProjectInfo> projects;

  const ProjectsSection({Key? key, required this.projects}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: projects.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProjectCard(project: projects[i]),
          );
        },
      ),
    );
  }
}

// Individual project card with image, title and description
class ProjectCard extends StatelessWidget {
  final ProjectInfo project;

  const ProjectCard({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Image.asset(
                project.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.code,
                    size: 30,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
          
          // Project title and description text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
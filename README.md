# Girantra

**Girantra** is a comprehensive Flutter-based mobile application acting as a marketplace to bridge buyers and sellers. The platform facilitates smooth online transactions, providing dedicated interfaces for both ordinary users (buyers) and registered sellers. It is backed by **Supabase** for secure authentication, real-time database management, and cloud storage.

## ✨ Features

### For Buyers
*   **Authentication & Profiles**: Secure sign-up/login, and advanced user profile management (edit details, upload profile picture).
*   **Product Browsing**: Clean and intuitive home screen with dynamic filtering (by category, price, rating).
*   **Wishlist & Favorites**: Easily save or "like" items to view them later.
*   **Shopping Cart & Checkout**: Integrated cart system with a seamless checkout flow.
*   **Notifications**: Stay updated with order status and generic system notifications.

### For Sellers
*   **Seller Registration**: Quick process for users to upgrade their accounts and become sellers.
*   **Dashboard & Management**: Specialized seller screens for managing product listings and analyzing activities.
*   **Product Uploads**: Integrated image picking capability using `image_picker`.

## 🛠 Tech Stack

*   **Frontend**: [Flutter](https://flutter.dev/) (Dart)
*   **Backend as a Service**: [Supabase](https://supabase.com/)
    *   Supabase Auth (Authentication)
    *   Supabase PostgreSQL (Database)
    *   Supabase Storage (Image hosting)
*   **Key Dependencies**:
    *   [`supabase_flutter`](https://pub.dev/packages/supabase_flutter): Official Supabase client for Flutter.
    *   [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv): Secure environment variable management.
    *   [`shared_preferences`](https://pub.dev/packages/shared_preferences): Local persistency.
    *   [`image_picker`](https://pub.dev/packages/image_picker): Access to device camera and gallery.

## 🚀 Getting Started

Follow these instructions to set up the project locally on your machine.

### Prerequisites
*   Flutter SDK (version 3.10.1 or higher)
*   Dart SDK
*   A Supabase account and project

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/girantra.git
    cd girantra
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Set up Environment Variables:**
    Create a `.env` file in the root of the project directory. Add your Supabase URL and API Key:
    ```env
    SUPABASE_URL=your_supabase_project_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    ```
    *Ensure `.env` is listed in your `pubspec.yaml` assets.*

4.  **Run the application:**
    ```bash
    flutter run
    ```
    *(For physical, wireless debug testing on Android, confirm ADB connection via TCP/IP or Android 11+ Wireless Debugging).*

## 📂 Project Structure Snapshot
While the app follows a component-based UI organization, some key folders include:
*   `lib/screens/`: Core user interface components separated by modules:
    *   `/auth`: Login, Register, Password flows.
    *   `/buyer`: Home screen, Cart interface, Checkout.
    *   `/seller`: Dashboard, Seller registration, Product listing UI.
    *   `/profile`: Profile summaries, Settings and Edit UI.
*   `lib/ui/`: Reusable, atomic widgets across the app (like `ProductCard`, `ProductListTile`, `FilterDialog`).

## 🤝 Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

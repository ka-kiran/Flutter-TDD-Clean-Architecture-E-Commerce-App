import 'package:auto_route/annotations.dart';
import 'package:eshop/presentation/views/main/cart/cart_view.dart';
import 'package:eshop/presentation/views/main/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

import 'category/category_view.dart';

@RoutePage(name: 'MainViewRoute')
class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedItemPosition = 0;
  final PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller,
              children:  <Widget>[
                const HomeView(),
                const CategoryView(),
                const CartView(),
                Container(),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 18,
            right: 18,
            child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: SnakeNavigationBar.color(
                behaviour: SnakeBarBehaviour.floating,
                snakeShape: SnakeShape.indicator,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(48)),
                ),
                backgroundColor: Colors.black87,
                snakeViewColor: Colors.black87,
                height: 68,
                elevation: 4,
                selectedItemColor: SnakeShape.circle == SnakeShape.indicator
                    ? Colors.black87
                    : null,
                unselectedItemColor: Colors.white,
                selectedLabelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    fontSize: 12
                ),
                showUnselectedLabels: false,
                showSelectedLabels: true,
                currentIndex: _selectedItemPosition,
                onTap: (index) => setState(() {
                  controller.animateToPage(index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.linear);
                  _selectedItemPosition = index;
                }),
                items: const [
                  BottomNavigationBarItem(
                      icon: Hero(
                        tag: '1',
                        child: ImageIcon(
                          AssetImage("assets/navbar_icons/home.png"),
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          maxRadius: 4,
                        ),
                      ),
                      label: 'Home'),
                  BottomNavigationBarItem(
                      icon: ImageIcon(
                        AssetImage("assets/navbar_icons/categories.png"),
                        color: Colors.white,
                        size: 26,
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          maxRadius: 4,
                        ),
                      ),
                      label: 'Category'),
                  BottomNavigationBarItem(
                      icon: ImageIcon(
                        AssetImage("assets/navbar_icons/shopping-cart.png"),
                        color: Colors.white,
                        size: 26,
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          maxRadius: 4,
                        ),
                      ),
                      label: 'Cart'),
                  BottomNavigationBarItem(
                      icon: ImageIcon(
                        AssetImage("assets/navbar_icons/user.png"),
                        color: Colors.white,
                        size: 26,
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          maxRadius: 4,
                        ),
                      ),
                      label: 'Other'),
                  // BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search')
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

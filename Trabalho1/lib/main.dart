import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color seedColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
      ),
      home: HomePage(
        onSelectColor: (Color color) {
          setState(() {
            seedColor = color;
          });
        },
        seedColor: seedColor,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(Color) onSelectColor;
  final Color seedColor;

  const HomePage(
      {super.key, required this.onSelectColor, required this.seedColor});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;
  final PageController _pageController = PageController();

  void _openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Seed Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: widget.seedColor,
            onColorChanged: widget.onSelectColor,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uber 2.0'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => _openColorPicker(context),
            tooltip: 'Choose Seed Color',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: const [
          PageOne(),
          PageTwo(),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Page One',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Page Two',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// class PageOne extends StatelessWidget {
//   const PageOne({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FlutterMap(
//         options: const MapOptions(
//           center: LatLng(-23.5505, -46.6333), // Coordenadas de exemplo (São Paulo)
//           zoom: 12.0,
//         ),
//         layers: [
//           TileLayerOptions(
//             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: ['a', 'b', 'c'],
//           ),
//           MarkerLayerOptions(
//             markers: [
//               Marker(
//                 width: 80.0,
//                 height: 80.0,
//                 point: LatLng(-23.5505, -46.6333),
//                 builder: (ctx) => const Icon(
//                   Icons.location_pin,
//                   color: Colors.red,
//                   size: 40,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Text('This is Page One', style: TextStyle(fontSize: 20)),
          // Conteúdo adicional para demonstrar o SingleChildScrollView
        ],
      ),
    );
  }
}

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Text('This is Page Two', style: TextStyle(fontSize: 18)),
          // Conteúdo adicional para demonstrar o SingleChildScrollView
        ],
      ),
    );
  }
}

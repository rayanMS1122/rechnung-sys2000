// import 'package:flutter/material.dart';
// import 'package:free_map/free_map.dart';
// import 'package:latlong2/latlong.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Free Map Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Karten Demo'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.map, size: 80, color: Colors.blue),
//             const SizedBox(height: 24),
//             const Text(
//               'Kostenlose Karte ohne API',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Mit OpenStreetMap',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const LocationPickerScreen(),
//                   ),
//                 );
//                 if (result != null && context.mounted) {
//                   final location = result as LatLng;
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         'Ausgewählt:\nLat: ${location.latitude.toStringAsFixed(6)}\nLng: ${location.longitude.toStringAsFixed(6)}',
//                       ),
//                       duration: const Duration(seconds: 4),
//                     ),
//                   );
//                 }
//               },
//               icon: const Icon(Icons.location_on),
//               label: const Text('Ort auswählen'),
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               ),
//             ),
//             const SizedBox(height: 16),
//             OutlinedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const MultipleMarkersScreen(),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.location_city),
//               label: const Text('Mehrere Marker anzeigen'),
//               style: OutlinedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class LocationPickerScreen extends StatefulWidget {
//   const LocationPickerScreen({super.key});

//   @override
//   State<LocationPickerScreen> createState() => _LocationPickerScreenState();
// }

// class _LocationPickerScreenState extends State<LocationPickerScreen> {
//   LatLng? _pickedLocation;
//   final MapController _mapController = MapController();

//   // Verschiedene Startpositionen
//   final List<Map<String, dynamic>> _locations = [
//     {'name': 'Münster', 'coords': LatLng(51.9625, 7.6251)},
//     {'name': 'Berlin', 'coords': LatLng(52.5200, 13.4050)},
//     {'name': 'München', 'coords': LatLng(48.1351, 11.5820)},
//     {'name': 'Hamburg', 'coords': LatLng(53.5511, 9.9937)},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ort auswählen'),
//         actions: [
//           // Zoom Controls
//           IconButton(
//             icon: const Icon(Icons.add),
//             tooltip: 'Zoom in',
//             onPressed: () {
//               final currentZoom = _mapController.camera.zoom;
//               _mapController.move(
//                 _mapController.camera.center,
//                 currentZoom + 1,
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.remove),
//             tooltip: 'Zoom out',
//             onPressed: () {
//               final currentZoom = _mapController.camera.zoom;
//               _mapController.move(
//                 _mapController.camera.center,
//                 currentZoom - 1,
//               );
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Karte
//           FmMap(
//             mapController: _mapController,
//             mapOptions: MapOptions(
//               initialCenter: LatLng(51.9625, 7.6251), // Münster
//               initialZoom: 13.0,
//               minZoom: 3.0,
//               maxZoom: 18.0,
//               onTap: (_, LatLng point) {
//                 setState(() {
//                   _pickedLocation = point;
//                 });
//               },
//             ),
//             markers: _pickedLocation != null
//                 ? [
//                     Marker(
//                       point: _pickedLocation!,
//                       child: const Icon(
//                         Icons.location_pin,
//                         color: Colors.red,
//                         size: 50,
//                       ),
//                     ),
//                   ]
//                 : [],
//           ),

//           // Ortsauswahl Dropdown
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: Material(
//               elevation: 4,
//               borderRadius: BorderRadius.circular(8),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: DropdownButton<LatLng>(
//                   isExpanded: true,
//                   underline: const SizedBox(),
//                   hint: const Text('Stadt auswählen'),
//                   items: _locations.map((loc) {
//                     return DropdownMenuItem<LatLng>(
//                       value: loc['coords'] as LatLng,
//                       child: Row(
//                         children: [
//                           const Icon(Icons.location_city, size: 20),
//                           const SizedBox(width: 8),
//                           Text(loc['name'] as String),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (LatLng? coords) {
//                     if (coords != null) {
//                       _mapController.move(coords, 13.0);
//                       setState(() {
//                         _pickedLocation = coords;
//                       });
//                     }
//                   },
//                 ),
//               ),
//             ),
//           ),

//           // Info Box unten
//           if (_pickedLocation != null)
//             Positioned(
//               bottom: 100,
//               left: 16,
//               right: 16,
//               child: Material(
//                 elevation: 4,
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.check_circle, color: Colors.green),
//                           SizedBox(width: 8),
//                           Text(
//                             'Position ausgewählt',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Latitude: ${_pickedLocation!.latitude.toStringAsFixed(6)}',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       Text(
//                         'Longitude: ${_pickedLocation!.longitude.toStringAsFixed(6)}',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: _pickedLocation != null
//           ? Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 FloatingActionButton(
//                   heroTag: 'confirm',
//                   onPressed: () {
//                     Navigator.pop(context, _pickedLocation);
//                   },
//                   child: const Icon(Icons.check),
//                 ),
//                 const SizedBox(height: 8),
//                 FloatingActionButton(
//                   heroTag: 'clear',
//                   backgroundColor: Colors.red,
//                   onPressed: () {
//                     setState(() {
//                       _pickedLocation = null;
//                     });
//                   },
//                   child: const Icon(Icons.clear),
//                 ),
//               ],
//             )
//           : null,
//     );
//   }
// }

// class MultipleMarkersScreen extends StatefulWidget {
//   const MultipleMarkersScreen({super.key});

//   @override
//   State<MultipleMarkersScreen> createState() => _MultipleMarkersScreenState();
// }

// class _MultipleMarkersScreenState extends State<MultipleMarkersScreen> {
//   final MapController _mapController = MapController();

//   // Beispiel-Standorte in Münster
//   final List<Map<String, dynamic>> _places = [
//     {
//       'name': 'Prinzipalmarkt',
//       'coords': LatLng(51.9606, 7.6261),
//       'color': Colors.red,
//       'icon': Icons.store,
//     },
//     {
//       'name': 'Münster Dom',
//       'coords': LatLng(51.9625, 7.6251),
//       'color': Colors.blue,
//       'icon': Icons.church,
//     },
//     {
//       'name': 'Aasee',
//       'coords': LatLng(51.9476, 7.6080),
//       'color': Colors.green,
//       'icon': Icons.water,
//     },
//     {
//       'name': 'Schloss',
//       'coords': LatLng(51.9634, 7.6115),
//       'color': Colors.purple,
//       'icon': Icons.castle,
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sehenswürdigkeiten in Münster'),
//       ),
//       body: Column(
//         children: [
//           // Karte
//           Expanded(
//             flex: 2,
//             child: FmMap(
//               mapController: _mapController,
//               mapOptions: MapOptions(
//                 initialCenter: LatLng(51.9606, 7.6261),
//                 initialZoom: 13.5,
//               ),
//               markers: _places.map((place) {
//                 return Marker(
//                   point: place['coords'] as LatLng,
//                   child: GestureDetector(
//                     onTap: () {
//                       _showPlaceInfo(place);
//                     },
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: place['color'] as Color,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             place['icon'] as IconData,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(4),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 blurRadius: 4,
//                               ),
//                             ],
//                           ),
//                           child: Text(
//                             place['name'] as String,
//                             style: const TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),

//           // Liste der Orte
//           Expanded(
//             flex: 1,
//             child: ListView.builder(
//               itemCount: _places.length,
//               itemBuilder: (context, index) {
//                 final place = _places[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 4,
//                   ),
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: place['color'] as Color,
//                       child: Icon(
//                         place['icon'] as IconData,
//                         color: Colors.white,
//                       ),
//                     ),
//                     title: Text(place['name'] as String),
//                     subtitle: Text(
//                       '${(place['coords'] as LatLng).latitude.toStringAsFixed(4)}, '
//                       '${(place['coords'] as LatLng).longitude.toStringAsFixed(4)}',
//                     ),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () {
//                       _mapController.move(
//                         place['coords'] as LatLng,
//                         15.0,
//                       );
//                       _showPlaceInfo(place);
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     // );
//   }

//   void _showPlaceInfo(Map<String, dynamic> place) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(
//               place['icon'] as IconData,
//               color: place['color'] as Color,
//             ),
//             const SizedBox(width: 8),
//             Text(place['name'] as String),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Koordinaten:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Lat: ${(place['coords'] as LatLng).latitude.toStringAsFixed(6)}',
//             ),
//             Text(
//               'Lng: ${(place['coords'] as LatLng).longitude.toStringAsFixed(6)}',
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Schließen'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// // import 'package:contacts_service/contacts_service.dart';
// import 'package:note_app/Google_Ads/ShowAds.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart'; // Add this import

// class ContactPage extends StatefulWidget {
//   const ContactPage({super.key});

//   @override
//   _ContactPageState createState() => _ContactPageState();
// }

// class _ContactPageState extends State<ContactPage> {
//   List<Contact> _contacts = [];
//   List<Contact> _filteredContacts = [];
//   List<Contact> _recycleBin = [];
//   bool _isSearchBarVisible = false;
//   TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//   }

//   Future<void> _checkPermissions() async {
//     if (await Permission.contacts.request().isGranted) {
//       _loadContacts();
//     } else {
//       _showPermissionDeniedDialog();
//     }
//   }

//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Permission Denied'),
//           content: const Text(
//               'Access to contacts is required to display the contact list.'),
//           actions: [
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _loadContacts() async {
//     try {
//       Iterable<Contact> contacts = await ContactsService.getContacts();
//       setState(() {
//         _contacts = contacts.toList();
//         _filteredContacts = _contacts;
//       });
//     } catch (e) {
//       print('Failed to load contacts: $e');
//     }
//   }

//   void _filterContacts(String query) {
//     setState(() {
//       _filteredContacts = _contacts.where((contact) {
//         return contact.displayName != null &&
//             contact.displayName!.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     });
//   }

//   void _toggleSearchBar() {
//     setState(() {
//       _isSearchBarVisible = !_isSearchBarVisible;
//       if (!_isSearchBarVisible) {
//         _searchController.clear();
//         _filterContacts('');
//       }
//     });
//   }

//   void _addContact() async {
//     final newContact = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AddContactPage()),
//     );
//     if (newContact != null) {
//       _loadContacts();
//     }
//   }

//   void _deleteContact(Contact contact) async {
//     setState(() {
//       _recycleBin.add(contact);
//       _contacts.remove(contact);
//       _filteredContacts.remove(contact);
//     });
//   }

//   void _shareContact(Contact contact) {
//     final contactInfo = 'Name: ${contact.displayName ?? ''}\n'
//         'Number: ${contact.phones?.isNotEmpty == true ? contact.phones!.first.value! : ''}\n'
//         'Email: ${contact.emails?.isNotEmpty == true ? contact.emails!.first.value! : ''}';
//     Share.share(contactInfo);
//   }

//   void _editContact(Contact contact) async {
//     final updatedContact = await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => EditContactPage(contact: contact)),
//     );
//     if (updatedContact != null) {
//       _loadContacts();
//     }
//   }

//   void _callContact(String phoneNumber) async {
//     final Uri launchUri = Uri(
//       scheme: 'tel',
//       path: phoneNumber,
//     );
//     await launch(launchUri.toString());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             IconButton(
//               icon: Icon(_isSearchBarVisible ? Icons.close : Icons.search),
//               onPressed: _toggleSearchBar,
//             ),
//             Expanded(
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 width: _isSearchBarVisible ? 250.0 : 0.0,
//                 child: _isSearchBarVisible
//                     ? TextField(
//                         controller: _searchController,
//                         onChanged: _filterContacts,
//                         decoration: const InputDecoration(
//                           hintText: 'Search contacts...',
//                           border: InputBorder.none,
//                         ),
//                       )
//                     : Container(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_add),
//             onPressed: _addContact,
//           ),
//         ],
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: ListView.builder(
//               itemCount: _filteredContacts.length,
//               itemBuilder: (context, index) {
//                 final contact = _filteredContacts[index];
//                 return Container(
//                   decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.all(Radius.circular(15)),
//                     gradient: LinearGradient(
//                       colors: [Color(0XFFE0EAFC), Color(0XFFCFDEF3)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                   child: ListTile(
//                     title: Text(contact.displayName ?? '',
//                         style: const TextStyle(color: Colors.black)),
//                     subtitle: Text(
//                         contact.phones?.isNotEmpty == true
//                             ? contact.phones!.first.value!
//                             : '',
//                         style: const TextStyle(color: Colors.black)),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           color: Colors.black,
//                           icon: const Icon(Icons.call_outlined),
//                           onPressed: () {
//                             if (contact.phones!.isNotEmpty) {
//                               _callContact(contact.phones!.first.value!);
//                             }
//                           },
//                         ),
//                         IconButton(
//                           color: Colors.black,
//                           icon: const Icon(Icons.ios_share_rounded),
//                           onPressed: () => _shareContact(contact),
//                         ),
//                         IconButton(
//                           color: Colors.black,
//                           icon: const Icon(Icons.delete_outline_outlined),
//                           onPressed: () => _deleteContact(contact),
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       ShowInterstitialAds().showClickInterstitialAds(
//                           callback: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ContactDetailPage(
//                                       contact: contact,
//                                       onEdit: () => _editContact(contact)),
//                                 ),
//                               ));
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ContactDetailPage extends StatelessWidget {
//   final Contact contact;
//   final VoidCallback onEdit;

//   const ContactDetailPage(
//       {super.key, required this.contact, required this.onEdit});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(contact.displayName ?? 'Contact Details'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: onEdit,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text('Name: ${contact.displayName ?? ''}'),
//             Text(
//                 'Number: ${contact.phones?.isNotEmpty == true ? contact.phones!.first.value! : ''}'),
//             Text(
//                 'Email: ${contact.emails?.isNotEmpty == true ? contact.emails!.first.value! : ''}'),
//             Text(
//                 'Address: ${contact.postalAddresses?.isNotEmpty == true ? contact.postalAddresses!.first.street! : ''}'),
//             Text('Company: ${contact.company ?? ''}'),
//             Text('Job Title: ${contact.jobTitle ?? ''}'),
//             // Additional fields can be displayed here if available
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AddContactPage extends StatefulWidget {
//   const AddContactPage({super.key});

//   @override
//   _AddContactPageState createState() => _AddContactPageState();
// }

// class _AddContactPageState extends State<AddContactPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _numberController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _companyController = TextEditingController();
//   final _jobTitleController = TextEditingController();
//   final _secondNumberController = TextEditingController();
//   final _designationController = TextEditingController();

//   void _saveContact() async {
//     if (_formKey.currentState!.validate()) {
//       Contact newContact = Contact(
//         givenName: _nameController.text,
//         phones: [
//           Item(label: 'mobile', value: _numberController.text),
//           if (_secondNumberController.text.isNotEmpty)
//             Item(label: 'mobile', value: _secondNumberController.text),
//         ],
//         emails: [
//           if (_emailController.text.isNotEmpty)
//             Item(label: 'email', value: _emailController.text),
//         ],
//         postalAddresses: [
//           if (_addressController.text.isNotEmpty)
//             PostalAddress(label: 'home', street: _addressController.text),
//         ],
//         company: _companyController.text,
//         jobTitle: _jobTitleController.text,
//       );
//       await ContactsService.addContact(newContact);
//       Navigator.pop(context, newContact);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Contact'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             onPressed: _saveContact,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: <Widget>[
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _numberController,
//                 decoration: const InputDecoration(labelText: 'Number'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a number';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an email';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(labelText: 'Address'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an address';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _companyController,
//                 decoration: const InputDecoration(labelText: 'Company'),
//                 validator: (value) {
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _jobTitleController,
//                 decoration: const InputDecoration(labelText: 'Job Title'),
//                 validator: (value) {
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _secondNumberController,
//                 decoration: const InputDecoration(labelText: 'Second Number'),
//                 validator: (value) {
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _designationController,
//                 decoration: const InputDecoration(labelText: 'Designation'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a designation';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class EditContactPage extends StatefulWidget {
//   final Contact contact;

//   const EditContactPage({super.key, required this.contact});

//   @override
//   _EditContactPageState createState() => _EditContactPageState();
// }

// class _EditContactPageState extends State<EditContactPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _numberController;
//   late TextEditingController _emailController;
//   late TextEditingController _addressController;
//   late TextEditingController _companyController;
//   late TextEditingController _jobTitleController;
//   late TextEditingController _secondNumberController;
//   late TextEditingController _designationController;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.contact.givenName);
//     _numberController = TextEditingController(
//         text: widget.contact.phones?.isNotEmpty == true
//             ? widget.contact.phones!.first.value
//             : '');
//     _emailController = TextEditingController(
//         text: widget.contact.emails?.isNotEmpty == true
//             ? widget.contact.emails!.first.value
//             : '');
//     _addressController = TextEditingController(
//         text: widget.contact.postalAddresses?.isNotEmpty == true
//             ? widget.contact.postalAddresses!.first.street
//             : '');
//     _companyController = TextEditingController(text: widget.contact.company);
//     _jobTitleController = TextEditingController(text: widget.contact.jobTitle);
//     _secondNumberController = TextEditingController(
//         text: widget.contact.phones?.length == 2
//             ? widget.contact.phones![1].value
//             : '');
//     _designationController =
//         TextEditingController(text: widget.contact.jobTitle);
//   }

//   void _saveContact() async {
//     if (_formKey.currentState!.validate()) {
//       Contact updatedContact = Contact(
//         givenName: _nameController.text,
//         phones: [
//           Item(label: 'mobile', value: _numberController.text),
//           if (_secondNumberController.text.isNotEmpty)
//             Item(label: 'mobile', value: _secondNumberController.text),
//         ],
//         emails: [
//           if (_emailController.text.isNotEmpty)
//             Item(label: 'email', value: _emailController.text),
//         ],
//         postalAddresses: [
//           if (_addressController.text.isNotEmpty)
//             PostalAddress(label: 'home', street: _addressController.text),
//         ],
//         company: _companyController.text,
//         jobTitle: _jobTitleController.text,
//       );
//       await ContactsService.updateContact(updatedContact);
//       Navigator.pop(context, updatedContact);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Contact'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             onPressed: _saveContact,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: <Widget>[
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _numberController,
//                 decoration: const InputDecoration(labelText: 'Number'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a number';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an email';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(labelText: 'Address'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an address';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _companyController,
//                 decoration: const InputDecoration(labelText: 'Company'),
//                 validator: (value) {
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _jobTitleController,
//                 decoration: const InputDecoration(labelText: 'Job Title'),
//                 validator: (value) {
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _secondNumberController,
//                 decoration: const InputDecoration(labelText: 'Second Number'),
//                 validator: (value) {
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _designationController,
//                 decoration: const InputDecoration(labelText: 'Designation'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a designation';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CustomSearchBar extends StatelessWidget {
//   final String hintText;
//   final Function(String) onSearch;

//   const CustomSearchBar(
//       {super.key, required this.hintText, required this.onSearch});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(1.0),
//       child: TextField(
//         onChanged: onSearch,
//         decoration: InputDecoration(
//           hintText: hintText,
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30.0),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.grey[200],
//           prefixIcon: const Icon(Icons.search),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:crafted_by_her/core/auth_view_model.dart';
import 'package:crafted_by_her/domain/models/product.dart';
import 'package:crafted_by_her/domain/models/product_categories.dart';
import 'package:crafted_by_her/presentation/main_screens.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'reusable_components/custom_text_field.dart';

class SuccessScreen extends StatelessWidget {
  final List<String> imageUrls;

  const SuccessScreen({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Product Submitted Successfully!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (imageUrls.isNotEmpty) ...[
                  const Text(
                    'Uploaded Image URLs:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...imageUrls.map((url) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          url,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.blue),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SellerFlowScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Add Another Product'),
                ),
              ],
            ),
          ),
        ));
  }
}

class SellerFlowScreen extends StatefulWidget {
  const SellerFlowScreen({super.key});

  @override
  State<SellerFlowScreen> createState() => _SellerFlowScreenState();
}

class _SellerFlowScreenState extends State<SellerFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productData = Provider.of<ProductData>(context, listen: false);
      if (productData.category == null &&
          productData.productName == null &&
          productData.price == null &&
          productData.images.isEmpty) {
        // Optional: Restore from temporary storage if implemented
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final productData = Provider.of<ProductData>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Product post',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          ProgressBar(currentStep: _currentStep, totalSteps: _totalSteps),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() {
                  _currentStep = page;
                });
              },
              children: const [
                Step1Screen(),
                Step2Screen(),
                Step3Screen(),
                Step4Screen(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: _currentStep == 0
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: _previousStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    child: const Text('Previous step'),
                  ),
                ElevatedButton(
                  onPressed: _currentStep < _totalSteps - 1
                      ? () {
                          final productData =
                              Provider.of<ProductData>(context, listen: false);
                          if (_currentStep == 0) {
                            if (productData.category != null &&
                                productData.productName != null &&
                                productData.productName!.isNotEmpty &&
                                productData.price != null &&
                                productData.price!.isNotEmpty) {
                              _nextStep();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please fill all required fields')),
                              );
                            }
                          } else {
                            _nextStep();
                          }
                        }
                      : () async {
                          await authViewModel.submitProduct(
                              productData, context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  child: _currentStep == _totalSteps - 1
                      ? const Text('Submit')
                      : const Text('Next step'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressBar(
      {super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final double progress = (currentStep + 1) / totalSteps;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStepIcon(Icons.person, 'Product Information', currentStep >= 0),
          _buildConnector(),
          _buildStepIcon(Icons.cloud_upload, 'Upload photo', currentStep >= 1),
          _buildConnector(),
          _buildStepIcon(Icons.check_circle, 'Submit', currentStep >= 2),
          _buildConnector(),
          _buildStepIcon(Icons.remove_red_eye, 'Review', currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildStepIcon(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.blue : Colors.grey[300],
            border: Border.all(
                color: isActive ? Colors.blue : Colors.grey, width: 2),
          ),
          child: Icon(icon,
              color: isActive ? Colors.white : Colors.grey, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Column(
      children: [
         AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            color: Colors.grey[400],
            child: CustomPaint(
              painter: DashedLinePainter(),
            ),
          ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        Paint()..color = Colors.grey[400]!,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Step1Screen extends StatefulWidget {
  const Step1Screen({super.key});

  @override
  State<Step1Screen> createState() => _Step1ScreenState();
}

class _Step1ScreenState extends State<Step1Screen> {
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productData = Provider.of<ProductData>(context, listen: false);
      _productNameController.text = productData.productName ?? '';
      _descriptionController.text = productData.description ?? '';
      _priceController.text = productData.price ?? '';
    });

    // Add listeners to update ProductData when text changes
    _productNameController.addListener(() {
      final productName = _productNameController.text;
      Provider.of<ProductData>(context, listen: false).updateProduct(productName: productName);
      print('Product name changed: $productName');
    });

    _descriptionController.addListener(() {
      final description = _descriptionController.text;
      Provider.of<ProductData>(context, listen: false).updateProduct(description: description);
      print('Description changed: $description');
    });

    _priceController.addListener(() {
      final price = _priceController.text;
      Provider.of<ProductData>(context, listen: false).updateProduct(price: price);
      print('Price changed: $price');
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductData>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Step 1/4',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tell us about your listing',
                style: TextStyle(fontSize: 20, fontFamily: 'DM Serif', fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField2<ProductCategory>(
                  value: ProductCategory.fromString(productData.category),
                  isExpanded: true,
                  decoration: InputDecoration(
                    focusColor: Colors.transparent,
                    labelText: 'category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color.fromARGB(140, 18, 18, 18)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    offset: Offset(MediaQuery.of(context).size.width - 180, 0),
                  ),
                  items: ProductCategory.values.map((ProductCategory productCategory) {
                    return DropdownMenuItem<ProductCategory>(
                      value: productCategory,
                      child: Text(
                        productCategory.toString().split('.').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (ProductCategory? newValue) {
                    productData.updateProduct(category: newValue?.name);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            customTextField(
              controller: _productNameController,
              textFieldTitle: 'Product Name',
              hintText: 'Enter product name',
            ),
            const SizedBox(height: 16),
            customTextField(
              controller: _descriptionController,
              textFieldTitle: 'Description',
              hintText: 'Enter description',
              isDescription: true
            ),
            const SizedBox(height: 16),
            customTextField(
              controller: _priceController,
              textFieldTitle: 'Price(ETB)',
              hintText: 'Enter price',
              // Optionally add keyboardType if supported by CustomTextField
              // keyboardType: TextInputType.number, // Uncomment if available
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class Step2Screen extends StatefulWidget {
  const Step2Screen({super.key});

  @override
  State<Step2Screen> createState() => _Step2ScreenState();
}

class _Step2ScreenState extends State<Step2Screen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAdditionalImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final productData = Provider.of<ProductData>(context, listen: false);
      if (productData.images.length < 10) {
        productData.addImages([pickedFile]); // Add single image to the list
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can select up to 10 images only.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductData>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Step 2/4',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Upload Photos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey, style: BorderStyle.solid, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_outlined,
                          size: 50, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('Drag & Drop here or',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ElevatedButton(
                        onPressed: _pickAdditionalImage,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        child: const Text('Select Additional Image'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                productData.images.isEmpty
                    ? const Text('No images selected')
                    : Expanded(
                        child: GridView.builder(
                          itemCount: productData.images.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      12), // Rounded corners
                                  child: Image.file(
                                    File(productData.images[index].path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red, size: 24),
                                    onPressed: () {
                                      productData.removeImage(index);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Step3Screen extends StatelessWidget {
  const Step3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductData>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 3/4',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review Your Listing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Category: ${productData.category ?? "Not set"}'),
            const SizedBox(height: 8),
            Text('Product Name: ${productData.productName ?? "Not set"}'),
            const SizedBox(height: 8),
            Text(
                'Description: ${productData.description ?? "No description provided"}'),
            const SizedBox(height: 8),
            Text('Price: ${productData.price ?? "Not set"} ETB'),
            const SizedBox(height: 16),
            const Text('Product preview images:'),
            const SizedBox(height: 8),
            productData.images.isEmpty
                ? const Text('No preview images selected.')
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productData.images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(productData.images[index].path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Please review your listing details!',
                style: TextStyle(
                    color: Colors.orange,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Step4Screen extends StatelessWidget {
  const Step4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Step 4/4',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Submit Your Listing',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your listing is ready to be submitted. Click the button below to finalize.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (viewModel.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    final productData =
                        Provider.of<ProductData>(context, listen: false);
                    final success =
                        await viewModel.submitProduct(productData, context);
                    if (success) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SuccessScreen(imageUrls: productData.imageUrls),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  child: const Text('Submit'),
                ),

              // Show SnackBar if there's an error
              if (viewModel.errorMessage != null)
                Builder(
                  builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Only females can publish product',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                    return const SizedBox(); // Empty widget to maintain tree structure
                  },
                ),
            ],
          )),
        );
      },
    );
  }
}

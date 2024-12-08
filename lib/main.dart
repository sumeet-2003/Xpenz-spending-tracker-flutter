import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() => runApp(const ExpenseTrackerApp());

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home page after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ExpenseHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color of the splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 150),
            const SizedBox(height: 20),
            const GradientText(
              'Xpenz',
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple,Colors.redAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            const Text("Track your Spending", style: TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final storedExpenses = prefs.getString('expenses') ?? '[]';
    setState(() {
      _expenses = List<Map<String, dynamic>>.from(jsonDecode(storedExpenses));
    });
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('expenses', jsonEncode(_expenses));
  }

  void _addExpense(String amount, String message) {
    setState(() {
      _expenses.add({
        'amount': double.parse(amount),
        'message': message,
        'date': DateTime.now().toIso8601String(),
      });
    });
    _saveExpenses();
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
    _saveExpenses();
  }

  List<Map<String, dynamic>> _groupExpensesByMonth() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var expense in _expenses) {
      final month = DateFormat('MMMM yyyy')
          .format(DateTime.parse(expense['date']));
      if (!grouped.containsKey(month)) grouped[month] = [];
      grouped[month]!.add(expense);
    }
    return grouped.entries
        .map((e) => {'month': e.key, 'expenses': e.value})
        .toList();
  }

  void _showAddExpenseForm() {
    final amountController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty &&
                  messageController.text.isNotEmpty) {
                _addExpense(
                  amountController.text,
                  messageController.text,
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedExpenses = _groupExpensesByMonth();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //SizedBox.fromSize(size: Size(20, 20),), // padding (top, bottom)
            Row(
              children: [
                 GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Xpenz: Developed by Sumeet ;)'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xff000000),
                    size: 30,
                  ),
                ),

                const SizedBox(width: 10),
                const GradientText(
                  'Xpenz:',
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple,Colors.redAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                const GradientText(
                  'Track Your Spendings',
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.purple,Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFffffff), // app bar background color
        elevation: 2,
      ),
      body: groupedExpenses.isEmpty
          ? const Center(
        child: Text(
          'No expenses added yet!',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: groupedExpenses.length,
        itemBuilder: (ctx, index) {
          final monthData = groupedExpenses[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  monthData['month'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              ...monthData['expenses'].asMap().entries.map<Widget>(
                    (entry) {
                  final expense = entry.value;
                  final expenseIndex = _expenses.indexOf(expense);
                  return GestureDetector(
                    onLongPress: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Expense?'),
                        content: const Text(
                            'Are you sure you want to delete this record?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _deleteExpense(expenseIndex);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red))
                          ),
                        ],
                      ),
                    ),
                    child: ListTile(
                      title: Text(expense['message'], style: const TextStyle(fontSize: 17),),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy')
                            .format(DateTime.parse(expense['date'])),
                      ),
                      trailing: Text(
                          '₹${expense['amount'].toStringAsFixed(2)}',style: const TextStyle(color: Colors.deepPurple, fontSize: 16),),
                    ),
                  );
                },
              ).toList(),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Total: ₹${monthData['expenses'].fold(0.0, (sum, e) => sum + e['amount']).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseForm,
          backgroundColor: const Color(0xfffc6982),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
      this.text, {super.key, 
        required this.gradient,
        this.style = const TextStyle(),
      });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

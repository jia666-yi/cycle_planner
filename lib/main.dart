import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '周期日程管家',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

// 日程数据模型
class Task {
  final String title;
  final int weekday; // 周几，1=周一，7=周日

  Task(this.title, this.weekday);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // 存储所有周期性任务
  List<Task> _tasks = [];

  // 添加任务对话框
  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    int selectedWeekday = 1; // 默认周一

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('添加周期日程'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '日程名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedWeekday,
                    decoration: const InputDecoration(
                      labelText: '重复星期',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('周一')),
                      DropdownMenuItem(value: 2, child: Text('周二')),
                      DropdownMenuItem(value: 3, child: Text('周三')),
                      DropdownMenuItem(value: 4, child: Text('周四')),
                      DropdownMenuItem(value: 5, child: Text('周五')),
                      DropdownMenuItem(value: 6, child: Text('周六')),
                      DropdownMenuItem(value: 7, child: Text('周日')),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedWeekday = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        _tasks.add(Task(titleController.text, selectedWeekday));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('添加'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 获取某天的所有任务
  List<Task> _getTasksForDay(DateTime day) {
    return _tasks.where((task) => task.weekday == day.weekday).toList();
  }

  // 获取有任务的日期（用于日历标记）
  List<DateTime> _getMarkedDays() {
    final markedDays = <DateTime>{};
    final today = DateTime.now();
    // 标记未来60天内有任务的日期
    for (int i = -30; i <= 30; i++) {
      final day = today.add(Duration(days: i));
      if (_getTasksForDay(day).isNotEmpty) {
        markedDays.add(DateTime.utc(day.year, day.month, day.day));
      }
    }
    return markedDays.toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasks = _getTasksForDay(_selectedDay);
    final markedDays = _getMarkedDays();

    return Scaffold(
      appBar: AppBar(
        title: const Text('周期日程管家'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 日历部分
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            // 在有任务的日期下面显示小圆点
            eventLoader: (day) {
              return _getTasksForDay(day);
            },
          ),
          // 分割线
          const Divider(height: 1),
          // 下方日程列表
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${_selectedDay.month}月${_selectedDay.day}日 日程',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (selectedTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('这天没有日程', style: TextStyle(color: Colors.grey)),
                  )
                else
                  ...selectedTasks.map(
                    (task) => ListTile(
                      leading: const Icon(Icons.event, color: Colors.blue),
                      title: Text(task.title),
                      subtitle: Text('每周${_weekdayToString(task.weekday)}'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // 添加按钮
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _weekdayToString(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }
}
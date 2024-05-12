import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_first_flutter_app/pages/task_page.dart';

class Task {
  final String taskName;
  final String taskDuration;
  final String taskDesc;

  Task({required this.taskName, required this.taskDuration, required this.taskDesc});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  final String username;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var tasks = <Task>[];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final ref = FirebaseDatabase.instance.ref();
    final taskTemp = <Task>[];
    final username = await ref
        .child("pomodorable/users/user${currentUser?.uid}/name")
        .get();

    final tasksSnapshot = await ref
        .child("pomodorable/tasks/user:${username.value}")
        .get();

    if (tasksSnapshot.exists) {
      final tasksData = tasksSnapshot.value as Map<dynamic, dynamic>;
      tasksData.forEach((taskId, taskData) {
        final taskName = taskData['taskName'] ?? '';
        final taskDuration = taskData['taskDuration'] ?? '';
        final taskDesc = taskData['taskDesc'] ?? '';
        taskTemp.add(Task(
          taskName: taskName,
          taskDuration: taskDuration,
          taskDesc: taskDesc,
        ));
      });
    }

    setState(() {
      tasks = taskTemp;
    });
  }

  Future<void> _showTaskDetails(Task task) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("${task.taskName}"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Task Duration: ${task.taskDuration}'),
                Text('Task Description: ${task.taskDesc}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showTaskDetails(tasks[index]);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25),
            child: Slidable(
              endActionPane: ActionPane(
                motion: StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      setState(() {
                        tasks.removeAt(index);
                      });
                    },
                    icon: Icons.delete,
                    backgroundColor: Colors.red.shade300,
                    borderRadius: BorderRadius.circular(12),
                  )
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      tasks[index].taskName,
                    ),
                    SizedBox(width: 20),
                    Text('Duration: ${tasks[index].taskDuration}'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddTaskButton() {
    return Positioned(
      bottom: 10,
      right: 20,
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskPage(username: widget.username)),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFE57373)),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 15)),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
            ),
          ),
          child: Text('Add Task'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/pink_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hello ${widget.username}",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage("images/naname.png"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTaskList(),
                  ],
                ),
              ),
            ),
            _buildAddTaskButton(),
          ],
        ),
      ),
    );
  }
}

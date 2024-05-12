import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter_app/pages/home_screen.dart';

class TaskPage extends StatefulWidget {
  final String username;

  const TaskPage({Key? key, required this.username}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskDurationController = TextEditingController();
  TextEditingController taskDescController = TextEditingController();
  TextEditingController timerDurationController = TextEditingController();

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
        taskTemp.add(Task(taskName: taskName, taskDuration: taskDuration));
      });
    }

    setState(() {
      tasks = taskTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color(0xFFFFCBCB),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/pink_bg.png"),
                fit: BoxFit.fill,
              ),
            ),
          ),
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
                          ),
                        ),
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage("images/naname.png"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: taskNameController,
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: taskDescController,
                    decoration: InputDecoration(
                      labelText: 'Task Desc',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: taskDurationController,
                    decoration: InputDecoration(
                      labelText: 'Task Duration',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: timerDurationController,
                    decoration: InputDecoration(
                      labelText: 'Timer Duration',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final ref = FirebaseDatabase.instance.ref();
                      final username = await ref
                          .child("pomodorable/users/user${currentUser?.uid}" +
                          "/name")
                          .get();

                      var taskId = DateTime
                          .now()
                          .millisecondsSinceEpoch
                          .toString();

                      FirebaseDatabase.instance
                          .ref()
                          .child(
                          "pomodorable/tasks/user:${username
                              .value}/taskId:$taskId")
                          .set({
                        "taskName": taskNameController.text,
                        "taskDesc": taskDescController.text,
                        "taskDuration": taskDurationController.text,
                        "timerDuration": timerDurationController.text,
                      }).then((_) {
                        taskNameController.clear();
                        taskDurationController.clear();
                        taskDescController.clear();
                        timerDurationController.clear();
                      }).catchError((error) {
                        print("Failed to create task: $error");
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen(username: widget.username)));
                    },
                    child: Text('Add Task'),
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

  class Task {
  final String taskName;
  final String taskDuration;

  Task({required this.taskName, required this.taskDuration});
}

class TaskWidget extends StatelessWidget {
  final Task task;

  const TaskWidget({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.taskName),
          Text('Duration: ${task.taskDuration}'),
        ],
      ),
    );
  }
}

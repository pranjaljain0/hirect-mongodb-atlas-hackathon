import 'package:flutter/material.dart';
import 'package:hirectt/data/JobProviderDetails.dart';
import 'package:hirectt/data/JobSeekerDetails.dart';
// import 'package:hirectt/screens/Chat/Chat.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AllChats extends StatefulWidget {
  final JobSeekerDetails? jobSeekerDetails;
  final JobProviderDetails? jobProviderDetails;
  final StreamChatClient client;

  const AllChats({
    Key? key,
    this.jobSeekerDetails,
    this.jobProviderDetails,
    required this.client,
  }) : super(key: key);

  @override
  State<AllChats> createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, _widget) {
        return StreamChat(
          client: widget.client,
          child: _widget,
        );
      },
      home: const ChannelListPage(),
    );

    // return Scaffold(
    //   body: SafeArea(
    //       child: Column(
    //     children: [
    // Container(
    //     height: 60,
    //     width: MediaQuery.of(context).size.width,
    //     decoration: const BoxDecoration(
    //       color: Colors.blueAccent,
    //     ),
    //     child: const Center(
    //         child: Padding(
    //       padding: EdgeInsets.all(8.0),
    //       child: Text(
    //         "All Chats",
    //         style: TextStyle(fontSize: 20, color: Colors.white),
    //       ),
    //     ))),
    //       Expanded(
    //           child: SingleChildScrollView(
    //         child: InkWell(
    //           onTap: () {
    //             Route route = MaterialPageRoute(
    //                 builder: (context) => const Scaffold(
    //                       body: SafeArea(child: Chat()),
    //                     ));
    //             Navigator.push(context, route);
    //           },
    //           child: Container(
    //             height: 80,
    //             width: double.infinity,
    //             decoration: const BoxDecoration(
    //                 border: Border(
    //                     bottom: BorderSide(
    //               color: Colors.black,
    //               width: 1,
    //             ))),
    //             child: Padding(
    //               padding: const EdgeInsets.all(10.0),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   const Text(
    //                     "John Doe",
    //                     style: TextStyle(fontSize: 20),
    //                   ),
    //                   const Text(
    //                     "Google",
    //                     style: TextStyle(fontSize: 16),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ))
    //     ],
    //   )),
    // );
  }
}

class ChannelListPage extends StatelessWidget {
  const ChannelListPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChannelsBloc(
        child: ChannelListView(
          filter: Filter.in_(
            'members',
            [StreamChat.of(context).currentUser!.id],
          ),
          sort: const [SortOption('last_message_at')],
          limit: 20,
          channelWidget: const ChannelPage(),
        ),
      ),
    );
  }
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChannelHeader(
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              threadBuilder: (_, parentMessage) => ThreadPage(
                parent: parentMessage,
              ),
            ),
          ),
          const MessageInput(),
        ],
      ),
    );
  }
}

class ThreadPage extends StatelessWidget {
  const ThreadPage({
    Key? key,
    this.parent,
  }) : super(key: key);

  final Message? parent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThreadHeader(
        parent: parent!,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              parentMessage: parent,
            ),
          ),
          MessageInput(
            parentMessage: parent,
          ),
        ],
      ),
    );
  }
}

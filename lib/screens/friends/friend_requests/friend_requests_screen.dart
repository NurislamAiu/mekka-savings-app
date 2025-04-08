import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/close_screen_button.dart';
import 'presentation/friend_requests_provider.dart';
import 'widgets/friend_request_card.dart';
import 'widgets/shimmer_list.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<FriendRequestsProvider>().loadRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendRequestsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFDEBD0), Color(0xFFE8F8F5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: provider.loadRequests,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Column(
                        children: [
                          SvgPicture.asset('assets/kaaba.svg', height: 40),
                          const SizedBox(height: 8),
                          Text(
                            '“Верующий для верующего подобен зданию, части которого укрепляют друг друга”',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '(Хадис от аль-Бухари и Муслима)',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      if (provider.isLoading)
                        const ShimmerList()
                      else if (provider.requests.isEmpty)
                        Column(
                          children: [
                            const SizedBox(height: 60),
                            Text(
                              "📭 Пока нет новых заявок",
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: provider.requests.map((req) {
                            return FriendRequestCard(
                              uid: req['uid'],
                              nickname: req['nickname'],
                              email: req['email'],
                              onAccept: () => provider.accept(req['uid']),
                              onDecline: () => provider.decline(req['uid']),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const CloseScreenButton(),
            ],
          ),
        );
      },
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mekka_savings_app/screens/friends/friend_add/data/friends_repository_impl.dart';
import 'package:mekka_savings_app/screens/friends/friend_add/domain/usecases/search_user_usecase.dart';
import 'package:mekka_savings_app/screens/friends/friend_add/domain/usecases/send_friend_request_usecase.dart';
import 'package:mekka_savings_app/screens/goals/my_shared_goals/domain/my_shared_goal_use_case.dart';
import 'package:mekka_savings_app/screens/goals/my_shared_goals/presentation/my_shared_goals_provider.dart';
import 'package:mekka_savings_app/screens/goals/shared_goal/presentation/shared_goal_provider.dart';
import 'package:mekka_savings_app/screens/profile/data/profile_repository.dart';
import 'package:mekka_savings_app/screens/profile/domain/profile_use_case.dart';
import 'package:mekka_savings_app/screens/profile/presentation/profile_provider.dart';
import 'package:provider/provider.dart';

import '../screens/auth/auth_screen.dart';
import '../screens/friends/friend_add/presentation/friends_provider.dart';
import '../screens/friends/friend_requests/data/friend_repository.dart';
import '../screens/friends/friend_requests/domian/friend_request_use_case.dart';
import '../screens/friends/friend_requests/presentation/friend_requests_provider.dart';
import '../screens/goals/create_my_goal/data/create_goal_repository.dart';
import '../screens/goals/create_my_goal/domain/create_goal_use_case.dart';
import '../screens/goals/create_my_goal/presentation/create_goal_provider.dart';
import '../screens/goals/create_shared_goal/data/create_shared_goal_repository.dart';
import '../screens/goals/create_shared_goal/domain/create_shared_goal_use_case.dart';
import '../screens/goals/create_shared_goal/presentation/create_shared_goal_provider.dart';
import '../screens/goals/my_shared_goals/data/my_shared_goal_repository.dart';
import '../screens/goals/shared_goal/data/shared_goal_repository.dart';
import '../screens/goals/shared_goal/domain/shared_goal_use_case.dart';
import '../screens/home/data/goal_repository.dart';
import '../screens/home/domain/goal_use_case.dart';
import '../screens/home/presentation/goal_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GoalProvider(useCase: GoalUseCase(GoalRepository())),
        ),
        ChangeNotifierProvider(
          create:
              (_) => CreateGoalProvider(
                useCase: CreateGoalUseCase(repository: CreateGoalRepository()),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => FriendRequestsProvider(
                useCase: FriendRequestUseCase(repository: FriendRepository()),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => FriendsProvider(
                searchUserUseCase: SearchUserUseCase(FriendsRepositoryImpl()),
                sendRequestUseCase: SendFriendRequestUseCase(FriendsRepositoryImpl()),
              ),
        ),

        ChangeNotifierProvider(
          create:
              (_) => CreateSharedGoalProvider(
                useCase: CreateSharedGoalUseCase(
                  repository: CreateSharedGoalRepository(),
                ),
              ),
        ),

        ChangeNotifierProvider(
          create:
              (_) => MySharedGoalsProvider(
                useCase: MySharedGoalUseCase(MySharedGoalRepository()),
              ),
        ),

        ChangeNotifierProvider(
          create:
              (_) => SharedGoalProvider(
                useCase: SharedGoalUseCase(repository: SharedGoalRepository()),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => ProfileProvider(
                useCase: ProfileUseCase(
                  repository: ProfileRepository(
                    firestore: FirebaseFirestore.instance,
                    auth: FirebaseAuth.instance,
                  ),
                ),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => ProfileProvider(
                useCase: ProfileUseCase(
                  repository: ProfileRepository(
                    firestore: FirebaseFirestore.instance,
                    auth: FirebaseAuth.instance,
                  ),
                ),
              ),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('ru'),
        debugShowCheckedModeBanner: false,
        supportedLocales: const [Locale('ru'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/auth': (context) => const AuthScreen(),
        },
      ),
    );
  }
}

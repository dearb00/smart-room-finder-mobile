import 'package:flutter/material.dart';

import '../models/roles.dart';
import '../models/room.dart';
import '../models/room_request.dart';

import 'dart:async';

import '../services/api_service.dart';

import '../theme/app_theme.dart';
import '../models/booking.dart';
import '../models/notification_model.dart';
import '../widgets/booking_form_sheet.dart';
import '../widgets/room_card.dart';
import '../widgets/smart_engine_overlay.dart';

/// Room Finder — available to Teacher and CR/GR only.
class RoomFinderScreen extends StatefulWidget {
  final AzhlyRole role;

  const RoomFinderScreen({
    super.key,
    required this.role,
  });

  @override
  State<RoomFinderScreen> createState() => _RoomFinderScreenState();
}

class _RoomFinderScreenState extends State<RoomFinderScreen> {
  int _tabIndex = 0;

  Timer? _refreshTimer;

  // Backend rooms
  List<Room> rooms = [];

  bool loading = true;

  bool get _isCrGr => widget.role == AzhlyRole.crGr;

  @override
  void initState() {
    super.initState();

    fetchRooms();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        fetchRooms();
      },
    );
  }

  Future<void> fetchRooms() async {
    try {
      final data = await ApiService().getRooms();

      setState(() {
        rooms = data;

        loading = false;
      });
    } catch (e) {
      debugPrint("Room loading error: $e");

      setState(() {
        loading = false;
      });
    }
  }

  void _bookRoom(Room room) {
    showBookingFormSheet(
      context,
      room: room,
      submitLabel: 'Request to Smart Engine',
      onSubmit: (teacherName, purpose, subject) async {
        try {
          await ApiService().requestBooking(
            studentName: teacherName,
            roomNo: room.roomNo,
            day: "Monday",
            timeSlot: room.timeSlot,
          );
          // Refresh room list immediately
          await fetchRooms();

          if (!mounted) return;
          await showSmartEngineOverlay(context);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Booking request sent to Smart Engine"),
            ),
          );
        } catch (e) {
          debugPrint("Booking Error: $e");
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Booking failed"),
            ),
          );
        }
      },
    );
  }

  Future<void> _approveRequest(RoomRequest request) async {
    final approved = await showSmartEngineOverlay(
      context,
      processingTitle: 'Forwarding to Teacher',
    );

    if (!mounted) return;

    // Update Booking Status
    BookingStore.updateStatus(
      request.id,
      approved ? BookingStatus.approved : BookingStatus.rejected,
    );

    // Student Notification
    NotificationStore.add(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: approved ? "Booking Approved" : "Booking Rejected",
        message: approved
            ? "Your room ${request.room.roomNo} has been approved."
            : "Your booking was rejected because of a conflict.",
        type: NotificationType.student,
      ),
    );

    // Admin Notification
    NotificationStore.add(
      AppNotification(
        id: "${DateTime.now().millisecondsSinceEpoch}admin",
        title: approved ? "New Approved Booking" : "Booking Conflict",
        message: "${request.studentName} • Room ${request.room.roomNo}",
        type: NotificationType.admin,
      ),
    );

    RoomRequestStore.remove(request.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approved ? "Approved" : "Rejected",
        ),
      ),
    );
  }

  void _rejectRequest(RoomRequest request) {
    BookingStore.updateStatus(
      request.id,
      BookingStatus.rejected,
    );

    NotificationStore.add(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Booking Rejected",
        message: "Your request for Room ${request.room.roomNo} was rejected.",
        type: NotificationType.student,
      ),
    );

    NotificationStore.add(
      AppNotification(
        id: "${DateTime.now().millisecondsSinceEpoch}admin",
        title: "Booking Rejected",
        message: "${request.studentName}'s request was rejected.",
        type: NotificationType.admin,
      ),
    );

    RoomRequestStore.remove(request.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Request Declined",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextDim
        : AppColors.lightTextDim;

    return Column(
      children: [
        if (_isCrGr)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              4,
            ),
            child: ValueListenableBuilder<List<RoomRequest>>(
              valueListenable: RoomRequestStore.pending,
              builder: (context, requests, _) {
                return Row(
                  children: [
                    _tabChip(
                      'Find Room',
                      0,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    _tabChip(
                      'Requests${requests.isNotEmpty ? ' (${requests.length})' : ''}',
                      1,
                    ),
                  ],
                );
              },
            ),
          ),
        Expanded(
          child: (_isCrGr && _tabIndex == 1)
              ? _buildRequestsTab(dimColor)
              : _buildFindRoomTab(),
        ),
      ],
    );
  }

  Widget _buildFindRoomTab() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (rooms.isEmpty) {
      return const Center(
        child: Text(
          "No rooms available",
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];

        return RoomCard(
          room: room,
          onTap: () => _bookRoom(room),
        );
      },
    );
  }

  Widget _buildRequestsTab(Color dimColor) {
    return ValueListenableBuilder<List<RoomRequest>>(
      valueListenable: RoomRequestStore.pending,
      builder: (context, requests, _) {
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No pending student requests',
              style: TextStyle(
                color: dimColor,
                fontSize: 12,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final r = requests[index];

            return _RequestCard(
              request: r,
              onApprove: () => _approveRequest(r),
              onReject: () => _rejectRequest(r),
            );
          },
        );
      },
    );
  }

  Widget _tabChip(String label, int index) {
    final selected = _tabIndex == index;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _tabIndex = index;
        });
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

class _RequestCard extends StatelessWidget {
  final RoomRequest request;

  final VoidCallback onApprove;

  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF25164F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF8B5CF6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏫 Room ${request.room.roomNo} • ${request.subject}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '👨‍🎓 From: ${request.studentName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '👩‍🏫 Teacher: ${request.teacherName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '📚 Purpose: ${request.purpose}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Reject",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Approve",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

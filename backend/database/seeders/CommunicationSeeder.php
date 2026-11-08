<?php

namespace Database\Seeders;

use App\Models\Notification;
use App\Models\Message;
use App\Models\CalendarEvent;
use App\Models\Event;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class CommunicationSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $institution = \App\Models\Institution::first();
        
        // Create notifications
        $notificationTypes = ['announcement', 'reminder', 'warning', 'system'];
        $priorities = ['low', 'medium', 'high', 'urgent'];
        
        for ($i = 1; $i <= 15; $i++) {
            Notification::create([
                'institution_id' => $institution->id,
                'title' => 'Notification ' . $i,
                'message' => 'This is the body of notification ' . $i . '. Important information for all users.',
                'type' => $notificationTypes[array_rand($notificationTypes)],
                'data' => ['category' => ['general', 'academic', 'administrative'][array_rand(['general', 'academic', 'administrative'])]],
                'priority' => $priorities[array_rand($priorities)],
                'is_read' => (bool) rand(0, 1),
                'created_at' => now()->subDays(rand(0, 30)),
            ]);
        }
        $this->command->info('Created: 15 notifications');

        // Create messages
        $messageTypes = ['parent-teacher', 'admin-staff', 'announcement'];
        $users = User::where('user_type', '!=', \App\Enums\UserAccountType::Parent)->get();
        $parents = User::where('user_type', \App\Enums\UserAccountType::Parent)->get();
        
        for ($i = 1; $i <= 25; $i++) {
            $sender = $users->random();
            $recipient = $parents->isNotEmpty() ? $parents->random() : null;
            
            Message::create([
                'institution_id' => $institution->id,
                'sender_id' => $sender->id,
                'subject' => 'Message Subject ' . $i,
                'message' => 'This is the content of message ' . $i . '. It contains important information regarding school activities.',
                'type' => $messageTypes[array_rand($messageTypes)],
                'recipient_id' => $recipient?->id,
                'data' => [],
                'is_read' => (bool) rand(0, 1),
                'created_at' => now()->subDays(rand(0, 30)),
            ]);
        }
        $this->command->info('Created: 25 messages');

        // Create calendar events
        $eventTypes = ['holiday', 'exam', 'sports', 'cultural', 'assembly'];
        
        for ($i = 1; $i <= 20; $i++) {
            $startDate = now()->addDays(rand(1, 60));
            $isAllDay = (bool) rand(0, 1);
            
            CalendarEvent::create([
                'institution_id' => $institution->id,
                'title' => 'Calendar Event ' . $i,
                'description' => 'Description for calendar event ' . $i . '. Scheduled date for important activities.',
                'type' => $eventTypes[array_rand($eventTypes)],
                'starts_at' => $startDate,
                'ends_at' => $isAllDay ? $startDate : $startDate->addHours(2),
                'all_day' => $isAllDay,
                'data' => [],
                'created_at' => now(),
            ]);
        }
        $this->command->info('Created: 20 calendar events');

        // Create events
        $eventStatuses = ['upcoming', 'ongoing', 'completed', 'cancelled'];
        
        for ($i = 1; $i <= 15; $i++) {
            $startDate = now()->addDays(rand(1, 30));
            $endDate = rand(1, 5) !== 1 ? $startDate->addDays(rand(1, 3)) : null;
            $isAllDay = (bool) rand(0, 1);
            
            Event::create([
                'institution_id' => $institution->id,
                'title' => 'School Event ' . $i,
                'description' => 'Description for school event ' . $i . '. This is a major school event.',
                'type' => $eventTypes[array_rand($eventTypes)],
                'start_date' => $startDate,
                'end_date' => $endDate,
                'start_time' => $isAllDay ? null : now()->setTime(rand(9, 17), rand(0, 59) * 60),
                'end_time' => $isAllDay ? null : now()->setTime(rand(18, 22), rand(0, 59) * 60),
                'all_day' => $isAllDay,
                'data' => [],
                'status' => $eventStatuses[array_rand($eventStatuses)],
                'created_at' => now()->subDays(rand(0, 14)),
            ]);
        }
        $this->command->info('Created: 15 events');
    }
}

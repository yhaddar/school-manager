<?php

namespace App\Http\Controllers\Api;

use App\Models\Assignment;
use App\Models\CalendarEvent;
use App\Models\Course;
use App\Models\Event;
use App\Models\Grade;
use App\Models\Message;
use App\Models\Notification;
use App\Models\Submission;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SearchController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'query' => 'required|string|max:255',
            'types' => 'nullable|array',
            'limit' => 'integer|min:1|max:100',
        ]);

        $query = $request->input('query');
        $types = $request->input('types');
        $limit = $request->input('limit', 20);

        $results = [];
        $searchableTypes = $types ?? ['all'];

        if (in_array('all', $searchableTypes) || in_array('notifications', $searchableTypes)) {
            $notifications = Notification::where('institution_id', $this->getInstitutionId())
                ->where('title', 'LIKE', "%{$query}%")
                ->orWhere('message', 'LIKE', "%{$query}%")
                ->limit(5)
                ->get()
                ->map(fn ($n) => [
                    'type' => 'notification',
                    'id' => $n->id,
                    'title' => $n->title,
                    'subtitle' => Str::limit($n->message, 100),
                    'created_at' => $n->created_at,
                    'priority' => $n->priority,
                ]);

            $results = array_merge($results, $notifications->toArray());
        }

        if (in_array('all', $searchableTypes) || in_array('messages', $searchableTypes)) {
            $messages = Message::where('institution_id', $this->getInstitutionId())
                ->where('subject', 'LIKE', "%{$query}%")
                ->orWhere('message', 'LIKE', "%{$query}%")
                ->limit(5)
                ->get()
                ->map(fn ($m) => [
                    'type' => 'message',
                    'id' => $m->id,
                    'title' => $m->subject,
                    'subtitle' => Str::limit($m->message, 100),
                    'created_at' => $m->created_at,
                    'is_read' => $m->is_read,
                ]);

            $results = array_merge($results, $messages->toArray());
        }

        if (in_array('all', $searchableTypes) || in_array('calendar-events', $searchableTypes)) {
            $calendarEvents = CalendarEvent::where('institution_id', $this->getInstitutionId())
                ->where('title', 'LIKE', "%{$query}%")
                ->orWhere('description', 'LIKE', "%{$query}%")
                ->limit(5)
                ->get()
                ->map(fn ($e) => [
                    'type' => 'calendar_event',
                    'id' => $e->id,
                    'title' => $e->title,
                    'subtitle' => Str::limit($e->description ?? '', 100),
                    'starts_at' => $e->starts_at,
                    'type_category' => $e->type,
                ]);

            $results = array_merge($results, $calendarEvents->toArray());
        }

        if (in_array('all', $searchableTypes) || in_array('events', $searchableTypes)) {
            $events = Event::where('institution_id', $this->getInstitutionId())
                ->where('title', 'LIKE', "%{$query}%")
                ->orWhere('description', 'LIKE', "%{$query}%")
                ->limit(5)
                ->get()
                ->map(fn ($e) => [
                    'type' => 'event',
                    'id' => $e->id,
                    'title' => $e->title,
                    'subtitle' => Str::limit($e->description ?? '', 100),
                    'start_date' => $e->start_date,
                    'status' => $e->status,
                ]);

            $results = array_merge($results, $events->toArray());
        }

        // Sort by date descending and limit results
        usort($results, fn ($a, $b) => 
            strcmp($b['created_at'] ?? $b['start_date'] ?? $b['starts_at'] ?? '', 
                   $a['created_at'] ?? $a['start_date'] ?? $a['starts_at'] ?? ''));

        return response()->json([
            'data' => array_slice($results, 0, $limit),
        ]);
    }

    private function getInstitutionId()
    {
        return request()->attributes->get('institution')->id;
    }
}

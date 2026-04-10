<?php

namespace App\Mail;

use App\Models\Events;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class EventNotificationMail extends Mailable
{
    use Queueable, SerializesModels;

    public Events $event;

    public function __construct(Events $event)
    {
        $this->event = $event;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Evenement a venir : ' . $this->event->Name,
        );
    }

    public function content(): Content
    {
        return new Content(
            markdown: 'emails.events.event-notification',
        );
    }

    public function attachments(): array
    {
        return [];
    }
}

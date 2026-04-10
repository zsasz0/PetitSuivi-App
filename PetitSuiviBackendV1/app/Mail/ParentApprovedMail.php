<?php

namespace App\Mail;

use App\Models\Account;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ParentApprovedMail extends Mailable
{
    use Queueable, SerializesModels;

    public Account $parent;

    public function __construct(Account $parent)
    {
        $this->parent = $parent;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Votre compte parent a ete approuve !',
        );
    }

    public function content(): Content
    {
        return new Content(
            markdown: 'emails.parents.approved',
        );
    }

    public function attachments(): array
    {
        return [];
    }
}

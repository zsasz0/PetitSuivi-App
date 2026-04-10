<?php

namespace App\Mail;

use App\Models\Account;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class TeacherCredentialsMail extends Mailable
{
    use Queueable, SerializesModels;

    public Account $teacher;
    public string $password;

    public function __construct(Account $teacher, string $password)
    {
        $this->teacher = $teacher;
        $this->password = $password;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Vos identifiants de connexion enseignant',
        );
    }

    public function content(): Content
    {
        return new Content(
            markdown: 'emails.teachers.credentials',
        );
    }

    public function attachments(): array
    {
        return [];
    }
}

<?php

namespace App\Mail;

use App\Models\Account;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class PasswordResetMail extends Mailable
{
    use Queueable, SerializesModels;

    public Account $account;
    public string $password;

    public function __construct(Account $account, string $password)
    {
        $this->account = $account;
        $this->password = $password;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Votre nouveau mot de passe',
        );
    }

    public function content(): Content
    {
        return new Content(
            markdown: 'emails.accounts.password-reset',
        );
    }

    public function attachments(): array
    {
        return [];
    }
}

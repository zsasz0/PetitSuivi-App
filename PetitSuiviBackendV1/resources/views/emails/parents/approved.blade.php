<x-mail::message>
# Compte approuve

Bonjour {{ $parent->Firstname }} {{ $parent->Lastname }},

Votre compte parent a ete approuve par l'administration.

Vous pouvez maintenant vous connecter a l'application avec votre email et votre mot de passe.

<x-mail::button :url="config('app.frontend_url') . '/login'">
Se connecter
</x-mail::button>

Merci,<br>
{{ config('mail.from.name', config('app.name')) }}
</x-mail::message>

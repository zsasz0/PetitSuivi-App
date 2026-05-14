<x-mail::message>
# Reinitialisation du mot de passe

Bonjour {{ $account->Firstname }} {{ $account->Lastname }},

Une demande de reinitialisation de mot de passe a ete effectuee pour votre compte.

Voici votre nouveau mot de passe temporaire :

**Email :** {{ $account->Email }}
**Mot de passe :** {{ $password }}

Veuillez vous connecter avec ce mot de passe puis le changer des que possible.

Merci,<br>
{{ config('mail.from.name', config('app.name')) }}
</x-mail::message>

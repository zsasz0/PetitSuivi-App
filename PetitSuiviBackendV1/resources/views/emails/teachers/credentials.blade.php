<x-mail::message>
# Bienvenue

Bonjour {{ $teacher->Firstname }} {{ $teacher->Lastname }},

Votre compte enseignant a ete cree ou mis a jour par l'administration.

Voici vos identifiants de connexion :

**Email :** {{ $teacher->Email }}
**Mot de passe :** {{ $password }}

<x-mail::button :url="config('app.frontend_url') . '/login'">
Se connecter
</x-mail::button>

Pour des raisons de securite, nous vous recommandons de changer ce mot de passe apres votre premiere connexion.

Merci,<br>
{{ config('mail.from.name', config('app.name')) }}
</x-mail::message>

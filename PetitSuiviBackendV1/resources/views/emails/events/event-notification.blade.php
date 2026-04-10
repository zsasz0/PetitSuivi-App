<x-mail::message>
# Evenement scolaire

Un nouvel evenement est prevu dans l'etablissement.

**Nom :** {{ $event->Name }}
**Date :** {{ $event->Date }}
**Horaire :** {{ substr((string) $event->Starttime, 0, 5) }} - {{ substr((string) $event->Endtime, 0, 5) }}

@if (!empty($event->Description))
**Description :** {{ $event->Description }}
@endif

<x-mail::button :url="config('app.frontend_url')">
Ouvrir l'application
</x-mail::button>

Merci,<br>
{{ config('mail.from.name', config('app.name')) }}
</x-mail::message>

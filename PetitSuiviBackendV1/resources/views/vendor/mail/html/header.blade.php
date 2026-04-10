<tr>
<td class="header" style="padding: 32px 0 24px; text-align: center;">
<a href="{{ $url }}" style="display: inline-flex; align-items: center; gap: 12px; text-decoration: none;">
<span style="display: inline-block; width: 52px; height: 52px; line-height: 52px; border-radius: 14px; background: #2563eb; color: #ffffff; font-size: 24px; font-weight: 700; text-align: center;">{{ strtoupper(substr((string) config('mail.from.name', config('app.name')), 0, 1)) }}</span>
<span style="color: #111827; font-size: 24px; font-weight: 700; letter-spacing: 0.2px;">{{ config('mail.from.name', config('app.name')) }}</span>
</a>
</td>
</tr>

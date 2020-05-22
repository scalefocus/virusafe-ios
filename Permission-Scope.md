ViruSafe iOS application requests following permissions:

<html>
<body>
<table align='center'>
<tr>
<th>
Permission scope
</th>
<th>
Why we need it
</th>
</tr>
<tr>
<td>Notifications</td>
<td>In order to keep users informed about when they have come into contact with someone who meets a set of criteria for a case of COVID-19. They might be used as a reminder for the users to update their health status or to provide them with the latest news.</td>
</tr>
<tr>
<td>Location</td>
<td>In order to compare your location to all users who have developed symptoms and to receive geo-based information about COVID-19.</td>
</tr>
<tr>
<td>Mobile Data</td>
<td>In order to communicate with the remote server which stores and provides all needed data for the application to operate with even when not connected to Wi-Fi network.</td>
</tr>
<tr>
<td>Background app refresh</td>
<td>In order to communicate location updates with the remote server.</td>
</tr>
</table>
</body>
</html>

> **NB!** The app requests permissions from the user using a standard system dialog.

> **NB!** The user can enable/disable those permissions from the OS settings menu at any moment. 

> **NB!** Turning off some permissions from the system menu may kill the background processes of the application, which is a system behaviour.

> **NB!** The app can not dictate an override of the user's default locale/language. Even though we provide localized descriptions, the one that matches OS preferred language will be shown. 

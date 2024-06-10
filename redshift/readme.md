the directory that redshift looks for it's config file is ~/.config/redshift.conf

this can be adjusted in the bspwmrc file and specify the config directory

-----------------------------------------

# Redshift

For FreeBSD 14 on X.Org/X11

**Cite:** [Installing RedShift on FreeBSD](https://loga.us/2018/10/24/freebsd-and-redshift-blue-light-suppression/)

## What is it?
Redshift is an open source project designed to adjust the color temperature of your monitor according to the time of day of your locale.  During the day, the color temperature should have more blue light and, as the day progresses to night, it transitions to warmer red light.  The purpose is to reduce eye fatigue and keep your circadian clock in check if working late hours on your computer.

## Installation Steps
To install Redshift on FreeBSD via the pkg method:

 - Step 1: Run the following command in the terminal.

	`# pkg install redshift`

That's it for installation.

## Configure Redshift
Redshift configuration file can be configured but first, you must created it manually in the following directory:

`~/.config/redshift.conf`

Sample Config File:

```
; Global settings for redshift
[redshift]
; Set the day and night screen temperatures
temp-day=5700
temp-night=3500

; Enable/Disable a smooth transition between day and night
; 0 will cause a direct change from day to night screen temperature.
; 1 will gradually increase or decrease the screen temperature.
transition=1

; Set the screen brightness. Default is 1.0.
;brightness=0.9
; It is also possible to use different settings for day and night
; since version 1.8.
brightness-day=0.7
brightness-night=0.4
; Set the screen gamma (for all colors, or each color channel
; individually)
gamma=0.8
;gamma=0.8:0.7:0.8
; This can also be set individually for day and night since
; version 1.10.
;gamma-day=0.8:0.7:0.8
;gamma-night=0.6

; Set the location-provider: 'geoclue', 'geoclue2', 'manual'
; type 'redshift -l list' to see possible values.
; The location provider settings are in a different section.
location-provider=geoclue2

; Set the adjustment-method: 'randr', 'vidmode'
; type 'redshift -m list' to see all possible values.
; 'randr' is the preferred method, 'vidmode' is an older API.
; but works in some cases when 'randr' does not.
; The adjustment method settings are in a different section.
adjustment-method=randr

; Configuration of the location-provider:
; type 'redshift -l PROVIDER:help' to see the settings.
; ex: 'redshift -l manual:help'
; Keep in mind that longitudes west of Greenwich (e.g. the Americas)
; are negative numbers.
; [manual]
; lat=48.1
; lon=11.6

; Configuration of the adjustment-method
; type 'redshift -m METHOD:help' to see the settings.
; ex: 'redshift -m randr:help'
; In this example, randr is configured to adjust screen 1.
; Note that the numbering starts from 0, so this is actually the
; second screen. If this option is not specified, Redshift will try
; to adjust _all_ screens.
; [randr]
; screen=1
```

**Note:**
Please read carefully the redshift.conf file above.  There are important clues to find the preferred location provider (redshift -l list) as well as the adjustment method (redshift -m list).  Also, the above configuration is only applicable to the specific user’s home directory which contains the ~/.config/redshift.conf file.

##Configuring geoclue:

Installing Redshift also installs a related pkg – geoclue.  Geoclue is a D-Bus service that provides location information.  Although not required to use geoclue for location data, it is useful if one travels in order to keep the timing of the color transition of your monitor correctly aligned with your locale.

In order to allow Redshift to use geoclue, add the following lines to /usr/local/etc/geoclue/geoclue.conf:

```
[redshift]
allowed=true
system=false
users=
```

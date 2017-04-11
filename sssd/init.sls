{% from "sssd/map.jinja" import sssd_settings with context %}

sssd:
  pkg.installed:
    - name: {{ sssd_settings['packages']|yaml }}
    
  # NOTE: sssd.conf *MUST* have the following permissions, or the sssd service
  # will refuse to start:
  #   user: root
  #   group: root
  #   mode: 0600
  file.managed:
    - name: {{ sssd_settings['conf_file']|yaml }}
    - template: jinja
    - source: salt://sssd/templates/sssd.conf.jinja
    - user: root
    - group: root
    - mode: '0600'
    - require:
      - pkg: sssd
  
  service.running:
    - name: {{ sssd_settings['service']|yaml }}
    - enable: true
    - require:
      - pkg: sssd
    - watch:
      - file: sssd

{# FIXME: Add support for multiple CA certs. Per-domain CA certs isn't
   supported right now.
#}
{% if sssd_settings['cacert_contents'] is defined %}
sssd_cacert:
  file.managed:
    - name: {{ sssd_settings['default_ldap_tls_cacert'] }}
    - template: jinja
    - source: salt://sssd/templates/cacert.pem.jinja
    - user: root
    - group: root
    - mode: '0400'
    - watch_in:
      - service: sssd
{% endif %}

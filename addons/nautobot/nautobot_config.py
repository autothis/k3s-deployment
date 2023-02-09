#nautobot_config.py

import os
import sys

from nautobot.core.settings import *  # noqa F401,F403
from nautobot.core.settings_funcs import is_truthy

#########################
#                       #
#    LDAP Settings      #
#                       #
#########################

###### Example LDAP config ######

#AUTHENTICATION_BACKENDS = [
#    'django_auth_ldap.backend.LDAPBackend',
#    'nautobot.core.authentication.ObjectPermissionBackend',
#]
#
#import ldap
#
#from django_auth_ldap.config import LDAPSearch, LDAPGroupQuery, NestedActiveDirectoryGroupType
#
#REMOTE_AUTH_ENABLED = True
#
## Server URI
#AUTH_LDAP_SERVER_URI = os.getenv("AUTH_LDAP_SERVER_URI", "")
#AUTH_LDAP_BIND_DN = os.getenv("AUTH_LDAP_BIND_DN", "")
#AUTH_LDAP_BIND_PASSWORD = os.getenv("AUTH_LDAP_BIND_PASSWORD", "")
#
## The following may be needed if you are binding to Active Directory.
#AUTH_LDAP_CONNECTION_OPTIONS = {
#    ldap.OPT_REFERRALS: 0
#}
#
## Set the DN and password for the Nautobot service account.
#AUTH_LDAP_GROUP_TYPE = NestedActiveDirectoryGroupType()
#
## Include this `ldap.set_option` call if you want to ignore certificate errors. This might be needed to accept a self-signed cert.
#ldap.set_option(ldap.OPT_X_TLS_REQUIRE_CERT, ldap.OPT_X_TLS_NEVER)
#
#
## If a user's DN is producible from their username, we don't need to search.
## - not wanted for those who keep their users in a variety of subfolders e.g. engineering.users
##AUTH_LDAP_USER_DN_TEMPLATE = "uid=%(user)s,ou=users,dc=example,dc=com"
#
## This search matches users with the sAMAccountName equal to the provided username. This is required if the user's
## username is not in their DN (Active Directory).
#AUTH_LDAP_USER_SEARCH = LDAPSearch('DC=autothis,DC=com,DC=au',
#                                   ldap.SCOPE_SUBTREE,
#                                   "(sAMAccountName=%(user)s)")
#
## users permitted to log in must be in one of these AD groups
#AUTH_LDAP_REQUIRE_GROUP = (
#    LDAPGroupQuery("CN=Nautobot - Engineer,OU=Nautobot,OU=Security Groups,DC=autothis,DC=com,DC=au")
#)
#
## setting user flags by group
#AUTH_LDAP_USER_FLAGS_BY_GROUP = {
#    # as per main config, we might need "is_active" duplicating AUTH_LDAP_REQUIRE_GROUP.
#    # try recycling the same union object instead of rebuilding from strings.
#    "is_active": AUTH_LDAP_REQUIRE_GROUP,
#    "is_staff": "CN=Nautobot - Engineer,OU=Nautobot,OU=Security Groups,DC=autothis,DC=com,DC=au",
#    # "is_superuser": ""  # we choose never to make more superusers by ldap
#}
#
## Mirroring LDAP groups with filter to allowed list
## as per django doc, this is not favored, instead use find_groups
## more: https://stackoverflow.com/questions/52062136/django-auth-ldap-mirror-groups-not-working
## https://django-auth-ldap.readthedocs.io/en/latest/permissions.html
#AUTH_LDAP_MIRROR_GROUPS = ["Nautobot - Engineer"]
#
## AUTH_LDAP_FIND_GROUP_PERMS = True
#
##
#AUTH_LDAP_GROUP_SEARCH = LDAPSearch('OU=Nautobot,OU=Security Groups,DC=autothis,DC=com,DC=au',
#                                    ldap.SCOPE_SUBTREE,
#                                    '(objectClass=group)')
#
#LOG_LDAP_TO_CONSOLE = True  # preempts file and should not be left running in prod
## LOG_LDAP_TO_FILE = True  # busted and commented out


#########################
#                       #
#    Azure AD Auth      #
#                       #
#########################


#AUTHENTICATION_BACKENDS = [
#    "social_core.backends.azuread.AzureADOAuth2",
#    "nautobot.core.authentication.ObjectPermissionBackend",
#]
#
#SOCIAL_AUTH_AZUREAD_OAUTH2_KEY = "<Client ID from Azure>"
#SOCIAL_AUTH_AZUREAD_OAUTH2_SECRET = "<Client Secret From Azure>"


#########################
#                       #
#   Optional settings   #
#                       #
#########################

# Enable installed plugins. Add the name of each plugin to the list. This requires a custom image so extra plugins have been disabled.
#PLUGINS = ["nautobot_ssot_vsphere","nautobot_device_onboarding","nautobot-golden-config","nautobot_plugin_nornir"]
PLUGINS = ["nautobot_plugin_nornir"]

# Plugins configuration settings. These settings are used by various plugins that the user may have installed.
# Each key in the dictionary is the name of an installed plugin and its value is a dictionary of settings.
PLUGINS_CONFIG = {
    # https://nornir.readthedocs.io/en/latest/configuration/index.html
    # https://nornir.readthedocs.io/en/latest/tutorial/install.html
    # https://nornir.readthedocs.io/en/latest/howto/handling_connections.html
    # https://nornir.readthedocs.io/en/latest/configuration/index.html
    'nautobot_plugin_nornir': {
        'nornir_settings': {
            "runner": {
                "plugin": "threaded",
                "options": {
                    "num_workers": 20,
                },
            },
        },
    },
    #"nautobot_golden_config": {
    #    "per_feature_bar_width": 0.15,
    #    "per_feature_width": 13,
    #    "per_feature_height": 4,
    #    "enable_backup": True,
    #    "enable_compliance": True,
    #    "enable_intended": True,
    #    "enable_sotagg": True,
    #    "sot_agg_transposer": None,
    #    "platform_slug_map": None,
    #},
    #"nautobot_ssot": {
    #    "hide_example_jobs": False,  # defaults to False if unspecified
    #},
    #"nautobot_ssot_vsphere": {
    #    "VSPHERE_URI": os.getenv("VSPHERE_URI"),
    #    "VSPHERE_USERNAME": os.getenv("VSPHERE_USERNAME"),
    #    "VSPHERE_PASSWORD": os.getenv("VSPHERE_PASSWORD"),
    #    "VSPHERE_VERIFY_SSL": is_truthy(os.getenv("VSPHERE_VERIFY_SSL", False)),
    #}
}
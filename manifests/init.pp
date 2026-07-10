# @summary Configure Policy-bot container
#
# @param datadir sets where to store the config file
# @param hostname is the hostname
# @param aws_access_key_id sets the AWS key to use for Route53 challenge
# @param aws_secret_access_key sets the AWS secret key to use for the Route53 challenge
# @param email sets the contact address for the certificate
# @param github_integration_id sets the integration ID for the GitHub app
# @param github_webhook_secret sets the webook secret for validating webhooks
# @param github_private_key sets the private key for the GitHub app
# @param github_client_id sets the Client ID for OAuth
# @param github_client_secret sets the Client Secret for OAuth
# @param session_key sets the cookie encryption key
# @param container_ip sets the IP address for the docker container
class policybot (
  String $datadir,
  String $hostname,
  String $aws_access_key_id,
  String $aws_secret_access_key,
  String $email,
  String $github_integration_id,
  String $github_webhook_secret,
  String $github_private_key,
  String $github_client_id,
  String $github_client_secret,
  String $session_key,
  String $container_ip = '172.17.0.2',
) {
  file { $datadir:
    ensure => directory,
  }

  file { "${datadir}/policy-bot.yml":
    ensure  => file,
    content => template('policybot/policy-bot.yml.erb'),
    notify  => Service['container@policybot'],
  }

  docker::container { 'policybot':
    image => 'palantirtechnologies/policy-bot:latest',
    args  => [
      "-v ${datadir}:/secrets",
    ],
    cmd   => '',
  }

  nginx::site { $hostname:
    proxy_target          => "http://${container_ip}:8091",
    aws_access_key_id     => $aws_access_key_id,
    aws_secret_access_key => $aws_secret_access_key,
    email                 => $email,
  }
}

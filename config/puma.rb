bind 'unix://./tmp/puma.sock'
pidfile './tmp/puma.pid'
state_path './tmp/puma.state'
stdout_redirect './log/application.log', './log/application.log', true

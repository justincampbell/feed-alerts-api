formatter = Lograge::Formatters::KeyValue.new

Que.log_formatter = proc do |data|
  case data[:event]
  when :job_unavailable
  else
    formatter.call(data)
  end
end

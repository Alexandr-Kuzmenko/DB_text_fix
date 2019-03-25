require 'mysql2'

def reset_db_column
  client = ''

  loop do
    begin
      client = Mysql2::Client.new(host: 'db09', username: 'loki',
                                  password: 'v4WmZip2K67J6Iq7NXC', database: 'applicant_tests')
      break
    rescue Exception => e
      p '# EXCEPTION_SQL_CONNECTION #'
      p e
    end
  end

  begin
    client.query("delete from hle_dev_test_alexandr_kuzmenko where clean_name like '';")
    hash = client.query("select id, candidate_office_name, clean_name, sentense
                        from hle_dev_test_alexandr_kuzmenko;")
    hash.to_a.map! do |elem|
      str = elem['candidate_office_name']
      # fixing mistake of '//' dividers
      loop do
        break unless str.index('//')

        str.gsub!('//', '/')
      end
      # fixing mistake of ',/' case, no data after comma
      loop do
        break unless str.index(',/')

        str.gsub!(',/', '/')
      end
      # fixing unnecessary dots
      str.delete! '.'
      # spliting string to parts to make right order
      mass_part = str.split('/')
      # relocating message parts
      repaired_string = ' '
      mass_part.map.with_index do |e, i|
        # fixing extra 'spaces'
        loop do
          break unless e.index('  ')

          e.gsub!('  ', ' ')
        end
        # fixing start and end spaces
        e.strip!
        # lower or apper case (basic settings)
        if i + 1 == mass_part.size && mass_part.size > 1
          e = e.split.map(&:capitalize).join(' ')
        else
          e.downcase!
        end
        # Parentheses case option
        if e.index(',')
          submass_part = e.split(',')
          submass_part.map!.with_index { |el, ind| ind.zero? ? el : el.split.map(&:capitalize).join(' ').insert(0, '(').insert(-1, ')') }
          e = submass_part.join(' ')
        end
        # Connecting message parts in right order
        if i + 1 == mass_part.size && i >= 1
          repaired_string.insert(0, e)
        elsif i.zero?
          repaired_string << "#{e} "
        else
          repaired_string << "and #{e} "
        end
      end
      # fixing doubled highway & Township
      str = repaired_string.strip!
      str.gsub!(/[tT][wW][pP]|[tT][oO][wW][nN][sS][hH][iI][pP]/, 'Township')
      loop do
        break unless str.index('Township Township')

        str.gsub!('Township Township', 'Township')
      end
      str.gsub!(/[hH][wW][yY]|[hH][iI][gG][hH][wW][aA][yY]/, 'Highway')
      loop do
        break unless str.index('Highway Highway')

        str.gsub!('Highway Highway', 'Highway')
      end
      elem['clean_name'] = str
      # updating DB
      client.query("update hle_dev_test_alexandr_kuzmenko set clean_name = \"#{elem['clean_name']}\"
                                                          where id = #{elem['id']};")
      client.query("update hle_dev_test_alexandr_kuzmenko set sentense = CONCAT(\"The candidate is running for the \",
                                                          clean_name, \" office.\") where id = #{elem['id']};")
    end
  rescue Exception => e
    p '# EXCEPTION_SQL_SAVE_EMPLOYEE #'
    p e
  end
  client.close
end

reset_db_column

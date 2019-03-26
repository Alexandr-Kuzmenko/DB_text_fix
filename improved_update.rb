require 'mysql2'

def reset_db_column
  client = ''

  loop do
    begin
      client = Mysql2::Client.new(host: '', username: '',
                                  password: '', database: '')
      break
    rescue Exception => e
      p '# EXCEPTION_SQL_CONNECTION #'
      p e
    end
  end

  begin
    client.query("delete from hle_dev_test_alexandr_kuzmenko where clean_name like '';")
    hash = client.query("select id, candidate_office_name, clean_name, sentence
                        from hle_dev_test_alexandr_kuzmenko;")
    hash.to_a.map! do |elem|
      str = elem['candidate_office_name']
      # fixing mistake of '//' dividers
      string_mistakes_fix str, '//'
      # fixing mistake of ',/' case, no data after comma
      string_mistakes_fix str, ',/'
      # fixing unnecessary dots
      str.delete! '.'
      # splitting string to parts to make right order
      mass_part = str.split('/')
      # relocating message parts
      repaired_string = ' '
      mass_part.map.with_index do |e, i|
        # fixing extra 'spaces'
        string_mistakes_fix e, '  ', ' '
        # fixing start and end spaces
        e.strip!
        # lower or upper case (basic settings)
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
      string_mistakes_fix str, 'Township Township', 'Township'
      str.gsub!(/[hH][wW][yY]|[hH][iI][gG][hH][wW][aA][yY]/, 'Highway')
      string_mistakes_fix str, 'Highway Highway', 'Highway'
      elem['clean_name'] = str
      # updating DB
      client.query("update hle_dev_test_alexandr_kuzmenko set clean_name = \"#{elem['clean_name']}\"
                                                          where id = #{elem['id']};")
      client.query("update hle_dev_test_alexandr_kuzmenko set sentence = CONCAT(\"The candidate is running for the \",
                                                          clean_name, \" office.\") where id = #{elem['id']};")
    end
  rescue Exception => e
    p '# EXCEPTION_SQL_SAVE_EMPLOYEE #'
    p e
  end
  client.close
end

def string_mistakes_fix(string, event, result = '/')
  loop do
    break unless string.index(event)

    string.gsub!(event, result)
  end
end

reset_db_column

class StatsRepo
  include PageBuilder

  def popular_contributions
    rows = Page.connection.execute(<<-SQL
      with popular_pages as (
        SELECT  properties ->> \'title\' as properties_title,
          COUNT(*) AS count_all
          FROM "ahoy_events"
          WHERE "ahoy_events"."name" = \'$view\' AND
          (position(\'Contribution:\' in properties ->> \'title\') <> 0)
          GROUP BY properties ->> \'title\' ORDER BY count_all desc
      )
      SELECT
        pages.title as link,
        CASE WHEN "popular_pages"."count_all" is NULL THEN 1 ELSE "popular_pages"."count_all" END as count_all
      FROM pages
      left outer join popular_pages
      on (pages.namespace || \':\' || pages.title) = popular_pages.properties_title
      where pages.namespace = \'Contribution\'
      order by count_all desc
      SQL
    )

    rows.map do |row|
      [row['link'], row['count_all']]
    end.to_h
  end

  def popular_contribution_pages
    pages = Page.find_by_sql(<<-SQL
    SELECT * FROM pages
    inner join
      (SELECT  properties ->> \'title\' as properties_title,
        COUNT(*) AS count_all
        FROM "ahoy_events"
        WHERE "ahoy_events"."name" = \'$view\' AND
        (position(\'Contribution:\' in properties ->> \'title\') <> 0)
        GROUP BY properties ->> \'title\' ORDER BY count_all desc LIMIT 5) as popular_pages
    on (pages.namespace || \':\' || pages.title) = properties_title
    order by count_all desc
    SQL
    )
    pages.map { |page| build_page_entity(page) }
  end

  def popular_pages(namespace)
    pages = Page.find_by_sql(<<-SQL
    SELECT * FROM pages
    inner join
      (SELECT  properties ->> 'title' as properties_title,
        COUNT(*) AS count_all
        FROM \"ahoy_events\"
        WHERE \"ahoy_events\".\"name\" = '$view' AND
        (position('#{namespace}:' in properties ->> 'title') <> 0)
        GROUP BY properties ->> 'title' ORDER BY count_all desc LIMIT 5) as popular_pages
    on (pages.namespace || ':' || pages.title) = properties_title
    order by count_all desc limit 5
    SQL
    )

    pages.map { |page| build_page_entity(page) }
  end

  def popular_technologies
    Rails.cache.fetch("popular_technologies", expires_in: 12.hours) do
      result = Triple.where('substring(object from 0 for 11) = \'Technology\'').group(:object).count

      strip_namespaces(result)
    end
  end

  def popular_features
    Rails.cache.fetch("popular_features", expires_in: 12.hours) do
      result = Triple.where('substring(object from 0 for 8) = \'Feature\'').group(:object).count

      strip_namespaces(result)
    end
  end

  def popular_languages
    Rails.cache.fetch("popular_languages", expires_in: 12.hours) do
      result = Triple.where('substring(object from 0 for 9) = \'Language\'').group(:object).count

      strip_namespaces(result)
    end
  end

  def popular_page_views(namespace)
    rows = Page.connection.execute(<<-SQL
      with popular_pages as (
        SELECT  properties ->> \'title\' as properties_title,
          COUNT(*) AS count_all
          FROM "ahoy_events"
          WHERE "ahoy_events"."name" = \'$view\' AND
          (position(\'#{namespace}:\' in properties ->> \'title\') <> 0)
          GROUP BY properties ->> \'title\' ORDER BY count_all desc
      )
      SELECT
        pages.title as link,
        CASE WHEN "popular_pages"."count_all" is NULL THEN 1 ELSE "popular_pages"."count_all" END as count_all
      FROM pages
      left outer join popular_pages
      on (pages.namespace || \':\' || pages.title) = popular_pages.properties_title
      where pages.namespace = \'#{namespace}\'
      order by count_all desc
      SQL
    )

    rows.map do |row|
      [row['link'], row['count_all']]
    end.to_h
  end

  def most_referenced_contributions
    Triple.where('position(\'Contribution\' in triples.object) = 1').group(:object).limit(200).order('count_all').count
  end

end

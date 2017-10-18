SELECT
  pages.id,
  COALESCE(page_changes.title, pages.title) as title,
  pages.namespace,
  COALESCE(page_changes.raw_content, pages.raw_content) as raw_content,
  COALESCE(page_changes.created_at, pages.created_at) as valid_from
FROM pages
left outer join page_changes on page_changes.page_id = pages.id

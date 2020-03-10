# config/sitemap.rb
SitemapGenerator::Sitemap.default_host = "https://www.markitplace.io" # Your Domain Name
SitemapGenerator::Sitemap.public_path = 'tmp/sitemap'
# Where you want your sitemap.xml.gz file to be uploaded.
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new( 
aws_access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
aws_secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
fog_provider: 'AWS',
fog_directory: "markitplace-sitemaps",
fog_region: "us-east-2"
)

# The full path to your bucket
SitemapGenerator::Sitemap.sitemaps_host = "https://markitplace-sitemaps.s3.amazonaws.com"
# The paths that need to be included into the sitemap.
SitemapGenerator::Sitemap.create do
    Article.find_each do |article|
     add article_path(article.slug_en, locale: :en)
     add article_path(article, locale: :nl) if article.slug_nl != ""
    end
    Project.find_each do |project|
     add project_path(project, locale: :en)
     add project_path(project, locale: :nl)
    end
    Page.find_each do |page|
     add page_path(page, locale: :en)
     add page_path(page, locale: :nl)
    end

    add "en/single-page"
    add "nl/single-page"
    add "nl/starters-website"
    add "en/starters-website"
    add "nl/website-op-maat"
    add "en/website-op-maat"
    add "nl/webapplicatie"
    add "en/webapplicatie"
    add "nl/website-analyse"
    add "en/website-analyse"
end
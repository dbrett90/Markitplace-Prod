# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.markitplace.io"
# pick a place safe to write the files
SitemapGenerator::Sitemap.public_path = 'tmp/'
# store on S3 using Fog (pass in configuration values as shown above if needed)
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(
    fog_provider: 'AWS',
    aws_access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
    aws_secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
    fog_directory: 'markitplace-sitemaps',
    fog_region: 'us-east-2')
# inform the map cross-linking where to find the other maps
SitemapGenerator::Sitemap.sitemaps_host = "http://s3-us-east-2.amazonaws.com/markitplace-sitemaps/"
# pick a namespace within your bucket to organize your maps
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'



# The paths that need to be included into the sitemap.
SitemapGenerator::Sitemap.create do
    add root_path, changefreq: 'daily'
    add contact_path, changefreq: 'daily'
    add partner_information_path, changefreq: 'daily'
    PlanType.find_each do |plan_type|
     add plan_type_path(plan_type), changefreq: 'daily'
    end
    Product.find_each do |product|
     add product_path(product), changefreq: 'daily'
    end
end
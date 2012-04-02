use Rack::Static, 
    :urls => ["/stylesheets", "/images"],
      :root => "public"

run lambda { |env|
    f = case env['PATH_INFO']
             when '/' then 'public/index.html'
             else "public/#{env['PATH_INFO'].slice(1..-1)}.html"
           end
    [
          200, 
          {
           'Content-Type'  => 'text/html', 
           'Cache-Control' => 'public, max-age=86400' 
          },
          File.open(f, File::RDONLY)
   ]
}

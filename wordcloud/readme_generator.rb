require_relative "./cloud_types"

class ReadmeGenerator
  WORD_CLOUD_URL = 'https://raw.githubusercontent.com/codemaker2015/word-cloud/master/wordcloud/wordcloud.png'
  ADDWORD = 'add'
  SHUFFLECLOUD = 'shuffle'
  INITIAL_COUNT = 3
  USER = "codemaker2015"

  def initialize(octokit:)
    @octokit = octokit
  end

  def generate
    participants = Hash.new(0)
    current_contributors = Hash.new(0)
    current_words_added = INITIAL_COUNT
    total_clouds = CloudTypes::CLOUDLABELS.length
    total_words_added = INITIAL_COUNT * total_clouds

    octokit.issues.each do |issue|
      participants[issue.user.login] += 1
      if issue.title.split('|')[1] != SHUFFLECLOUD && issue.labels.any? { |label| CloudTypes::CLOUDLABELS.include?(label.name) }
        total_words_added += 1
        if issue.labels.any? { |label| label.name == CloudTypes::CLOUDLABELS.last }
          current_words_added += 1
          current_contributors[issue.user.login] += 1
        end
      end
    end

    markdown = <<~HTML

## Join the Community Word Cloud :cloud: :pencil2:

![](https://img.shields.io/badge/Words%20Added-#{total_words_added}-brightgreen?labelColor=7D898B)
![](https://img.shields.io/badge/Word%20Clouds%20Created-#{total_clouds}-48D6FF?labelColor=7D898B)
![](https://img.shields.io/badge/Total%20Participants-#{participants.size}-AC6EFF?labelColor=7D898B)

### :thought_balloon: [Add a word](https://github.com/codemaker2015/word-cloud/issues/new?template=addword.md&title=wordcloud%7C#{ADDWORD}%7C%3CINSERT-WORD%3E) to see the word cloud update in real time :rocket:

A new word cloud will be automatically generated when you [add your own word](https://github.com/codemaker2015/word-cloud/issues/new?template=addword.md&title=wordcloud%7C#{ADDWORD}%7C%3CINSERT-WORD%3E). The prompt will change frequently, so be sure to come back and check it out :relaxed:

:star2: Don't like the arrangement of the current word cloud? [Regenerate it](https://github.com/codemaker2015/word-cloud/issues/new?template=shufflecloud.md&title=wordcloud%7C#{SHUFFLECLOUD}) :game_die:

<div align="center">

## #{CloudTypes::CLOUDPROMPTS.last}

<img src="#{WORD_CLOUD_URL}" alt="WordCloud" width="100%">

![Word Cloud Words Badge](https://img.shields.io/badge/Words%20in%20this%20Cloud-#{current_words_added}-informational?labelColor=7D898B)
![Word Cloud Contributors Badge](https://img.shields.io/badge/Contributors%20this%20Cloud-#{current_contributors.size}-blueviolet?labelColor=7D898B)

    HTML

    # TODO: [![Github Badge](https://img.shields.io/badge/-@username-24292e?style=flat&logo=Github&logoColor=white&link=https://github.com/username)](https://github.com/username)

    current_contributors.each do |username, count|
      markdown.concat("[![Github Badge](https://img.shields.io/badge/-@#{format_username(username)}-24292e?style=flat&logo=Github&logoColor=white&link=https://github.com/#{username})](https://github.com/#{username}) ")
    end

    markdown.concat("\n\n Check out the [previous word cloud](#{previous_cloud_url}) to see our community's **#{CloudTypes::CLOUDPROMPTS[-2]}**")

    markdown.concat("</div>")

    markdown.concat("\n\n ### Need more games? Check out [connect4](https://github.com/codemaker2015/connect4) [chess](https://github.com/codemaker2015/chess)")
  end

  private

  def format_username(name)
    name.gsub('-', '--')
  end

  def previous_cloud_url
    url_end = CloudTypes::CLOUDPROMPTS[-2].gsub(' ', '-').gsub(':', '').gsub('?', '').downcase
    "https://github.com/codemaker2015/codemaker2015/blob/master/previous_clouds/previous_clouds.md##{url_end}"
  end

  attr_reader :octokit
end

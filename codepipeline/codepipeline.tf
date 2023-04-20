# resource "aws_codepipeline" "codepipeline" {
#   name     = "tf-test-pipeline"
#   role_arn = aws_iam_role.codepipeline_role.arn
  
#   artifact_store {
#     location = aws_s3_bucket.codepipeline_bucket.bucket
#     type     = "S3"

    
#   }

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "CodeStarSourceConnection"
#       version          = "1"
#       output_artifacts = ["source_output"]
      
      

#       configuration = {
#         ConnectionArn    = aws_codestarconnections_connection.example.arn
#         FullRepositoryId = "aprajain/website-aws"
#         BranchName       = "master"
        
#       }
      
#     }
#   }

# #   stage {
# #     name = "Build"

# #     action {
# #       name             = "Build"
# #       category         = "Build"
# #       owner            = "AWS"
# #       provider         = "CodeBuild"
# #       input_artifacts  = ["source_output"]
# #       output_artifacts = ["build_output"]
# #       version          = "1"

# #       configuration = {
# #         ProjectName = "test"
# #       }
# #     }
# #   }

#   stage {
#     name = "Deploy"

#     action {
#       name            = "Deploy"
#       category        = "Deploy"
#       owner           = "AWS"
#       provider        = "CodeDeploy"
#       input_artifacts = ["source_output"]
#       version         = "1"
    

#       configuration = {
#         ApplicationName="app1"
#         DeploymentGroupName="app1-dg"

#       }
#     }
#   }
# }

# resource "aws_codestarconnections_connection" "example" {
#   name          = "con3"
#   provider_type = "GitHub"
# }

# resource "aws_s3_bucket" "codepipeline_bucket" {
#   bucket = "qwaszxedc"
 
# }

# resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
#   bucket = aws_s3_bucket.codepipeline_bucket.id
#   acl    = "private"
# }

# data "aws_iam_policy_document" "assume_role2"{
#      statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["codepipeline.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }



# data "aws_iam_policy_document" "codepipeline_policy" {
   
#   statement {
#     effect = "Allow"

#     actions = [
#       "s3: *",
#     ]

#     resources = [
#       aws_s3_bucket.codepipeline_bucket.arn,
#       "${aws_s3_bucket.codepipeline_bucket.arn}/*"
#     ]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["codestar-connections:*"]
#     resources = [aws_codestarconnections_connection.example.arn]
#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "codebuild:BatchGetBuilds",
#       "codebuild:StartBuild",
#       "codedeploy:*"
#     ]


#     resources = ["*"]
#   }
# }
# resource "aws_iam_role" "codepipeline_role" {
#   name               = "test-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role2.json
# }

# resource "aws_iam_role_policy" "codepipeline_policy" {
#   name   = "codepipeline_policy"
#   role   = aws_iam_role.codepipeline_role.id
#   policy = data.aws_iam_policy_document.codepipeline_policy.json
# }


resource "aws_iam_role" "T_EC2_SSM_Role" {
  name = "T_EC2_SSM_Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "T_SSM_Policy_Attachment" {
  name       = "T_SSM_Policy_Attachment"
  roles      = [aws_iam_role.T_EC2_SSM_Role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "T_EC2_Instance_Profile" {
  name = "T_EC2_Instance_Profile"
  role = aws_iam_role.T_EC2_SSM_Role.name
}